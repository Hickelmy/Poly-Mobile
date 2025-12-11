import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço de armazenamento seguro para dados sensíveis
class SecureStorage {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  
  final FlutterSecureStorage _storage;
  
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );
  
  // ============ TOKEN ============
  
  /// Salva o token de acesso
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  /// Recupera o token de acesso
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  /// Verifica se existe token salvo
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Remove o token de acesso
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  // ============ REFRESH TOKEN ============
  
  /// Salva o refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
  
  /// Recupera o refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  /// Remove o refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }
  
  // ============ USER INFO ============
  
  /// Salva o ID do usuário
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }
  
  /// Recupera o ID do usuário
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
  
  /// Salva o email do usuário
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }
  
  /// Recupera o email do usuário
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }
  
  /// Salva o cargo do usuário
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }
  
  /// Recupera o cargo do usuário
  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }
  
  // ============ SESSION ============
  
  /// Salva todos os dados da sessão
  Future<void> saveSession({
    required String token,
    String? refreshToken,
    required String userId,
    required String email,
    required String role,
  }) async {
    await Future.wait([
      saveToken(token),
      if (refreshToken != null) saveRefreshToken(refreshToken),
      saveUserId(userId),
      saveUserEmail(email),
      saveUserRole(role),
    ]);
  }
  
  /// Limpa todos os dados da sessão
  Future<void> clearSession() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userRoleKey),
    ]);
  }
  
  /// Limpa todos os dados armazenados
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

