import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef TokenRefreshCallback =
    void Function(String accessToken, String refreshToken);
typedef LogoutCallback = void Function();

class AuthInterceptor extends Interceptor {
  static TokenRefreshCallback? onTokenRefreshed;
  static LogoutCallback? onLogout;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      // Do not try to refresh if the request itself was login or refresh
      if (requestPath.contains('/auth/refresh') ||
          requestPath.contains('/auth/login')) {
        return super.onError(err, handler);
      }

      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null || refreshToken.isEmpty) {
        onLogout?.call();
        return super.onError(err, handler);
      }

      try {
        // Create an isolated Dio instance to perform the refresh call
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: dotenv.env['API_URL'] ?? 'https://api-priora.quipu.club',
          ),
        );

        final response = await refreshDio.post(
          '/auth/refresh',
          options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final newAccessToken = response.data['accessToken'] as String;
          final newRefreshToken = response.data['refreshToken'] as String;

          await prefs.setString('accessToken', newAccessToken);
          await prefs.setString('refreshToken', newRefreshToken);

          onTokenRefreshed?.call(newAccessToken, newRefreshToken);

          // Retry the original request with the new access token
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Use the global dio instance to fetch again
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (refreshErr) {
        print('Token refresh failed: $refreshErr');
        // Clear tokens from SharedPreferences to make sure we don't try again
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        onLogout?.call();
        return super.onError(err, handler);
      }
    }
    return super.onError(err, handler);
  }
}

final dio =
    Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_URL'] ?? 'https://api-priora.quipu.club',
          connectTimeout: null,
          receiveTimeout: null,
          sendTimeout: null,
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
    const int chunkSize = 800;
    if (message.length <= chunkSize) {
      print(message);
      return;
    }

    int startIndex = 0;
    while (startIndex < message.length) {
      int endIndex = startIndex + chunkSize;
      if (endIndex >= message.length) {
        print(message.substring(startIndex));
        break;
      } else {
        print('${message.substring(startIndex, endIndex)} \\');
      }
      startIndex = endIndex;
    }
  }

  String _toCurl(RequestOptions options) {
    final List<String> components = ['curl -i --location'];

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
    return "'${arg.replaceAll("'", "'\\''")}'";
  }
}
