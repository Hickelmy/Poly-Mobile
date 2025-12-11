/// Exceções customizadas para o app POLYS
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exceção de rede/conexão
class NetworkException extends AppException {
  NetworkException({
    super.message = 'Erro de conexão com o servidor',
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

/// Exceção de servidor
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    super.message = 'Erro no servidor',
    super.code = 'SERVER_ERROR',
    super.details,
    this.statusCode,
  });
}

/// Exceção de autenticação
class AuthException extends AppException {
  AuthException({
    super.message = 'Erro de autenticação',
    super.code = 'AUTH_ERROR',
    super.details,
  });
}

/// Exceção de token expirado
class TokenExpiredException extends AuthException {
  TokenExpiredException({
    super.message = 'Sessão expirada. Faça login novamente.',
    super.code = 'TOKEN_EXPIRED',
    super.details,
  });
}

/// Exceção de credenciais inválidas
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException({
    super.message = 'Email ou senha incorretos',
    super.code = 'INVALID_CREDENTIALS',
    super.details,
  });
}

/// Exceção de validação
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException({
    super.message = 'Erro de validação',
    super.code = 'VALIDATION_ERROR',
    super.details,
    this.errors,
  });
}

/// Exceção de recurso não encontrado
class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'Recurso não encontrado',
    super.code = 'NOT_FOUND',
    super.details,
  });
}

/// Exceção de permissão negada
class ForbiddenException extends AppException {
  ForbiddenException({
    super.message = 'Você não tem permissão para esta ação',
    super.code = 'FORBIDDEN',
    super.details,
  });
}

/// Exceção de cache/armazenamento local
class CacheException extends AppException {
  CacheException({
    super.message = 'Erro no armazenamento local',
    super.code = 'CACHE_ERROR',
    super.details,
  });
}

/// Exceção de localização
class LocationException extends AppException {
  LocationException({
    super.message = 'Erro ao obter localização',
    super.code = 'LOCATION_ERROR',
    super.details,
  });
}

/// Exceção de permissão de localização negada
class LocationPermissionDeniedException extends LocationException {
  LocationPermissionDeniedException({
    super.message = 'Permissão de localização negada',
    super.code = 'LOCATION_PERMISSION_DENIED',
    super.details,
  });
}

