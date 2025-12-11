import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Repositório de autenticação
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Realiza login e retorna token + usuário
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final userData = data['user'] as Map<String, dynamic>;

      return AuthResult(
        token: token,
        user: UserModel.fromJson(userData),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao realizar login',
        details: e.toString(),
      );
    }
  }

  /// Realiza cadastro e retorna token + usuário
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': 'USER',
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      // Verifica se retorna token diretamente ou se precisa fazer login
      if (data.containsKey('access_token')) {
        final token = data['access_token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        return AuthResult(
          token: token,
          user: UserModel.fromJson(userData),
        );
      }
      
      // Se não retorna token, faz login automaticamente
      return await login(email: email, password: password);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao realizar cadastro',
        details: e.toString(),
      );
    }
  }

  /// Obtém dados do usuário atual
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.currentUser);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao obter dados do usuário',
        details: e.toString(),
      );
    }
  }

  /// Realiza logout (opcional, dependendo da API)
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignora erros de logout
    }
  }
}

/// Resultado da autenticação
class AuthResult {
  final String token;
  final UserModel user;

  AuthResult({
    required this.token,
    required this.user,
  });
}

