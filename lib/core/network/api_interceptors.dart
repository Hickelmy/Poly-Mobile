import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// Interceptor para adicionar token de autenticação
class AuthInterceptor extends Interceptor {
  final SecureStorage secureStorage;
  
  AuthInterceptor({required this.secureStorage});
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Não adiciona token em rotas públicas
    final publicPaths = ['/auth/login', '/auth/register'];
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
    // Se receber 401, limpa a sessão
    if (err.response?.statusCode == 401) {
      await secureStorage.clearSession();
    }
    handler.next(err);
  }
}

/// Interceptor para logging de requisições (apenas em debug)
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '📤 REQUEST[${options.method}] => PATH: ${options.path}',
      name: 'API',
    );
    developer.log(
      '   Headers: ${options.headers}',
      name: 'API',
    );
    if (options.data != null) {
      developer.log(
        '   Body: ${options.data}',
        name: 'API',
      );
    }
    if (options.queryParameters.isNotEmpty) {
      developer.log(
        '   Query: ${options.queryParameters}',
        name: 'API',
      );
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      name: 'API',
    );
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      name: 'API',
      error: err.message,
    );
    if (err.response?.data != null) {
      developer.log(
        '   Response: ${err.response?.data}',
        name: 'API',
      );
    }
    handler.next(err);
  }
}

/// Interceptor para tratamento global de erros
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Pode adicionar lógica adicional como analytics, crashlytics, etc
    handler.next(err);
  }
}

