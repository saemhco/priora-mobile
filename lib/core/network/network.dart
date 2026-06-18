import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: dotenv.env['API_URL'] ?? 'https://api-priora.quipu.club',
  ),
)..interceptors.add(CurlInterceptor());

class CurlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        final curl = _toCurl(options);
        print('🚀 [REQUEST] --------------------------------------------------');
        _printLog(curl);
        print('--------------------------------------------------------------');
      } catch (e) {
        print('Failed to generate curl: $e');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        print('🟢 [RESPONSE] [${response.statusCode} ${response.statusMessage ?? ''}] ------------------');
        print('URL: ${response.requestOptions.method} ${response.requestOptions.uri}');
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
        print('🔴 [RESPONSE ERROR] [${response?.statusCode ?? 'No Status'} ${response?.statusMessage ?? ''}] -----------');
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
            components.add('--form ${_escapeShellArg("${field.key}=${field.value}")}');
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
