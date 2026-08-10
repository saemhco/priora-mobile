import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef TokenRefreshCallback =
    void Function(String accessToken, String refreshToken);
typedef LogoutCallback = void Function();

class _PendingRequest {
  _PendingRequest({
    required this.requestOptions,
    required this.handler,
  });
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
}

class AuthInterceptor extends Interceptor {
  static TokenRefreshCallback? onTokenRefreshed;
  static LogoutCallback? onLogout;

  static bool _isRefreshing = false;
  static final List<_PendingRequest> _pendingRequests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 errors
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    final requestPath = err.requestOptions.path;

    // If this is already a retry or an auth endpoint → don't retry, logout
    if (err.requestOptions.extra['isRetry'] == true ||
        requestPath.contains('/auth/refresh') ||
        requestPath.contains('/auth/login')) {
      if (err.requestOptions.extra['isRetry'] == true) {
        await _clearTokensAndLogout();
      }

      return super.onError(err, handler);
    }

    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearTokensAndLogout();

      return super.onError(err, handler);
    }

    // If we're already refreshing the token, queue this request
    if (_isRefreshing) {
      _pendingRequests.add(
        _PendingRequest(
          requestOptions: err.requestOptions,
          handler: handler,
        ),
      );
      return;
    }

    // Start refreshing the token
    _isRefreshing = true;

    try {
      final refreshSuccess = await _performTokenRefresh(refreshToken);

      if (refreshSuccess) {
        // Get the new access token from SharedPreferences
        final newAccessToken = prefs.getString('accessToken') ?? '';

        // Retry the original request that triggered the refresh
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        err.requestOptions.extra['isRetry'] = true;

        try {
          final retryResponse = await dio.fetch<dynamic>(err.requestOptions);
          handler.resolve(retryResponse);
        } catch (retryError) {
          // Si el reintento también falla por autenticación (401) → logout.
          // Si falla por error de negocio (400/403/404…) → propagar el error
          // al caller para que muestre el mensaje, sin desloguear.
          final retryStatus = retryError is DioException
              ? retryError.response?.statusCode
              : null;
          if (retryStatus == 401) {
            await _clearTokensAndLogout();
            _rejectPendingRequests(err);
            return;
          }
          _rejectPendingRequests(
            retryError is DioException ? retryError : err,
          );
          if (retryError is DioException) {
            handler.next(retryError);
          } else {
            handler.next(err);
          }
          return;
        }

        // Success: retry all queued pending requests
        await _retryPendingRequests();
      } else {
        // Token refresh failed → logout and reject all pending
        await _clearTokensAndLogout();
        _rejectPendingRequests(err);
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await _clearTokensAndLogout();
      _rejectPendingRequests(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _retryPendingRequests() async {
    if (_pendingRequests.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final newToken = prefs.getString('accessToken') ?? '';
    final pendingList = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final pending in pendingList) {
      pending.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      pending.requestOptions.extra['isRetry'] = true;
      try {
        final response = await dio.fetch<dynamic>(pending.requestOptions);
        pending.handler.resolve(response);
      } catch (e) {
        pending.handler.next(
          DioException(
            requestOptions: pending.requestOptions,
            error: e,
            message: 'Error after token refresh',
          ),
        );
      }
    }
  }

  void _rejectPendingRequests(DioException originalError) {
    if (_pendingRequests.isEmpty) return;
    final pendingList = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    for (final pending in pendingList) {
      pending.handler.next(originalError);
    }
  }

  Future<bool> _performTokenRefresh(String refreshToken) async {
    try {
      // Create an isolated Dio instance without interceptors
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_URL'] ?? 'https://api-priora.quipu.club',
        ),
      );

      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null) {
          final newAccessToken = data['accessToken'] as String?;
          final newRefreshToken = data['refreshToken'] as String?;

          if (newAccessToken == null || newAccessToken.isEmpty) {
            return false;
          }

          final prefs = await SharedPreferences.getInstance();
          // Save new tokens to SharedPreferences
          await prefs.setString('accessToken', newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await prefs.setString('refreshToken', newRefreshToken);
          }

          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh request failed: $e');
      return false;
    }
  }

  Future<void> _clearTokensAndLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
    }
    onLogout?.call();
  }
}

final dio =
    Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_URL'] ?? 'https://api-priora.quipu.club',
        ),
      )
      ..interceptors.add(AuthInterceptor())
      ..interceptors.add(CurlInterceptor());

class CurlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        final curl = _toCurl(options);
        print(
          '🚀 [REQUEST] --------------------------------------------------',
        );
        _printLog(curl);
        print('--------------------------------------------------------------');
      } catch (e) {
        print('Failed to generate curl: $e');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      try {
        print(
          '🟢 [RESPONSE] [${response.statusCode} ${response.statusMessage ?? ''}] ------------------',
        );
        print(
          'URL: ${response.requestOptions.method} ${response.requestOptions.uri}',
        );
        final data = response.data;
        if (data != null) {
          print('Body:');
          if (data is Map || data is List) {
            const encoder = JsonEncoder.withIndent('  ');
            _printLog(encoder.convert(data));
          } else {
            _printLog(data.toString());
          }
        }
        print('--------------------------------------------------------------');
      } catch (e) {
        print('Failed to print response: $e');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        final response = err.response;
        print(
          '🔴 [RESPONSE ERROR] [${response?.statusCode ?? 'No Status'} ${response?.statusMessage ?? ''}] -----------',
        );
        print('URL: ${err.requestOptions.method} ${err.requestOptions.uri}');
        if (err.message != null) {
          print('Error Message: ${err.message}');
        }
        if (response?.data != null) {
          print('Body:');
          final data = response!.data;
          if (data is Map || data is List) {
            const encoder = JsonEncoder.withIndent('  ');
            _printLog(encoder.convert(data));
          } else {
            _printLog(data.toString());
          }
        }
        print('--------------------------------------------------------------');
      } catch (e) {
        print('Failed to print error response: $e');
      }
    }
    handler.next(err);
  }

  void _printLog(String message) {
    const chunkSize = 800;
    if (message.length <= chunkSize) {
      if (kDebugMode) {
        print(message);
      }
      return;
    }

    var startIndex = 0;
    while (startIndex < message.length) {
      final endIndex = startIndex + chunkSize;
      if (endIndex >= message.length) {
        if (kDebugMode) {
          print(message.substring(startIndex));
        }
        break;
      } else {
        if (kDebugMode) {
          print('${message.substring(startIndex, endIndex)} \\');
        }
      }
      startIndex = endIndex;
    }
  }

  String _toCurl(RequestOptions options) {
    final components = <String>['curl -i --location'];

    // Method
    components.add('-X ${options.method}');

    // Headers
    options.headers.forEach((k, v) {
      if (k != 'cookie') {
        components.add('-H ${_escapeShellArg("$k: $v")}');
      }
    });

    // Body / Data
    try {
      final data = options.data;
      if (data != null) {
        if (data is FormData) {
          for (final field in data.fields) {
            components.add(
              '--form ${_escapeShellArg("${field.key}=${field.value}")}',
            );
          }
          for (final file in data.files) {
            components.add(
              '--form ${_escapeShellArg("${file.key}=@${file.value.filename ?? 'file'}")}',
            );
          }
        } else if (data is Map || data is List) {
          final jsonStr = jsonEncode(data);
          components.add('-d ${_escapeShellArg(jsonStr)}');
        } else {
          components.add('-d ${_escapeShellArg(data.toString())}');
        }
      }
    } catch (e) {
      components.add('# [Error parsing body: $e]');
    }

    // Query parameters / URI (placed last)
    try {
      final uri = options.uri;
      components.add(_escapeShellArg(uri.toString()));
    } catch (e) {
      components.add(_escapeShellArg('${options.baseUrl}${options.path}'));
    }

    return components.join(' ');
  }

  String _escapeShellArg(String arg) {
    return "'${arg.replaceAll("'", r"'\''")}'";
  }
}
