import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';
import 'api_interceptors.dart';

/// Cliente HTTP para comunicação com a API
class ApiClient {
  late final Dio _dio;
  final SecureStorage secureStorage;
  
  ApiClient({
    required this.secureStorage,
    Dio? dio,
  }) {
    _dio = dio ?? Dio();
    _configureDio();
  }
  
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
  
  /// Atualiza a URL base da API
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
  
  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Upload de arquivo
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileFieldName,
    Map<String, dynamic>? data,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fileFieldName: await MultipartFile.fromFile(filePath),
      });
      
      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Trata erros do Dio e converte para exceções customizadas
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Tempo limite de conexão excedido',
          details: error.message,
        );
        
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Não foi possível conectar ao servidor',
          details: error.message,
        );
        
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
        
      case DioExceptionType.cancel:
        return AppException(
          message: 'Requisição cancelada',
          code: 'REQUEST_CANCELLED',
        );
        
      default:
        return AppException(
          message: 'Erro desconhecido',
          code: 'UNKNOWN_ERROR',
          details: error.message,
        );
    }
  }
  
  /// Trata respostas de erro do servidor
  AppException _handleBadResponse(Response? response) {
    if (response == null) {
      return ServerException(message: 'Resposta vazia do servidor');
    }
    
    final statusCode = response.statusCode;
    final data = response.data;
    final message = data is Map ? data['message'] ?? 'Erro no servidor' : 'Erro no servidor';
    
    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          details: data,
        );
        
      case 401:
        final errorMessage = message.toString().toLowerCase();
        if (errorMessage.contains('expired') || errorMessage.contains('expirado')) {
          return TokenExpiredException();
        }
        return InvalidCredentialsException(message: message);
        
      case 403:
        return ForbiddenException(message: message);
        
      case 404:
        return NotFoundException(message: message);
        
      case 422:
        return ValidationException(
          message: message,
          details: data,
          errors: data is Map ? data['errors'] : null,
        );
        
      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Erro interno do servidor',
          statusCode: statusCode,
          details: data,
        );
        
      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
          details: data,
        );
    }
  }
}

