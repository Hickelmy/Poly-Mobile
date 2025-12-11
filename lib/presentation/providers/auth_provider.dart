import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Estado da autenticação
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider de autenticação
class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  late final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  bool _isInitialized = false;

  AuthProvider({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage {
    _authRepository = AuthRepository(apiClient: _apiClient);
  }

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isInitialized => _isInitialized;

  /// Verifica se o usuário é admin
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Verifica se o usuário é gestor
  bool get isGestor => _user?.isGestor ?? false;
  
  /// Verifica se o usuário é manager (alias para isGestor)
  bool get isManager => _user?.isGestor ?? false;

  /// Verifica se pode criar projetos
  bool get canCreateProjects => _user?.canCreateProjects ?? false;

  /// Inicializa o provider verificando token existente
  Future<void> initialize() async {
    if (_isInitialized) return;

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final hasToken = await _secureStorage.hasToken();
      
      if (hasToken) {
        // Tenta obter dados do usuário atual
        try {
          _user = await _authRepository.getCurrentUser();
          _status = AuthStatus.authenticated;
        } on TokenExpiredException {
          await _secureStorage.clearSession();
          _status = AuthStatus.unauthenticated;
        } catch (_) {
          // Token inválido ou erro de rede
          await _secureStorage.clearSession();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Realiza login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      // Salva sessão
      await _secureStorage.saveSession(
        token: result.token,
        userId: result.user.id,
        email: result.user.email,
        role: result.user.role,
      );

      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on InvalidCredentialsException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } on AppException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao fazer login. Tente novamente.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Realiza cadastro
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );

      // Salva sessão
      await _secureStorage.saveSession(
        token: result.token,
        userId: result.user.id,
        email: result.user.email,
        role: result.user.role,
      );

      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } on AppException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao criar conta. Tente novamente.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (_) {
      // Ignora erros de logout na API
    }

    await _secureStorage.clearSession();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Atualiza dados do usuário localmente
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Recarrega dados do usuário
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      _user = await _authRepository.getCurrentUser();
      notifyListeners();
    } catch (_) {
      // Mantém dados atuais em caso de erro
    }
  }
}

