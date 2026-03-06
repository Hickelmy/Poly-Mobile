import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

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
      return AuthResult.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao realizar login',
        details: e.toString(),
      );
    }
  }

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

      if (data.containsKey('access_token')) {
        return AuthResult.fromJson(data);
      }

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

  Future<AuthResult> loginWithGoogle({required String idToken}) async {
    try {
      final response = await _apiClient.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      final data = response.data as Map<String, dynamic>;
      return AuthResult.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao fazer login com Google',
        details: e.toString(),
      );
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _apiClient.post(
        ApiEndpoints.logout,
        data: refreshToken != null ? {'refresh_token': refreshToken} : null,
      );
    } catch (_) {
      // Ignora erros de logout
    }
  }
}

class AuthResult {
  final String token;
  final String? refreshToken;
  final UserModel user;

  AuthResult({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> data) {
    return AuthResult(
      token: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String?,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}
