import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage.dart';

/// Interceptor para adicionar token de autenticação e auto-refresh
class AuthInterceptor extends Interceptor {
  final SecureStorage secureStorage;
  bool _isRefreshing = false;

  AuthInterceptor({required this.secureStorage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final publicPaths = ['/auth/login', '/auth/register', '/auth/google', '/auth/refresh'];
    if (publicPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    final token = await secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await secureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await secureStorage.clearSession();
          _isRefreshing = false;
          return handler.next(err);
        }

        final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
        final response = await dio.post('/auth/refresh', data: {
          'refresh_token': refreshToken,
        });

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final newToken = data['access_token'] as String;
          final newRefreshToken = data['refresh_token'] as String;

          await secureStorage.saveToken(newToken);
          await secureStorage.saveRefreshToken(newRefreshToken);

          // Retry the original request
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';

          final retryDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
          final retryResponse = await retryDio.fetch(retryOptions);
          _isRefreshing = false;
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        await secureStorage.clearSession();
      }

      _isRefreshing = false;
    }

    handler.next(err);
  }
}

/// Interceptor para logging de requisições
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      'REQUEST[${options.method}] => ${options.path}',
      name: 'API',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
      name: 'API',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      'ERROR[${err.response?.statusCode}] => ${err.requestOptions.path}',
      name: 'API',
      error: err.message,
    );
    handler.next(err);
  }
}

/// Interceptor para tratamento global de erros
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
