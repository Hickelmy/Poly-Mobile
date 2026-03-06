import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_provider.dart';

/// Provider de usuários
class UserProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final UserRepository _userRepository;
  AuthProvider? _authProvider;

  List<UserModel> _users = [];
  UserModel? _selectedUser;
  bool _isLoading = false;
  String? _error;

  UserProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _userRepository = UserRepository(apiClient: _apiClient);
  }

  // Getters
  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Atualiza referência ao AuthProvider
  void updateAuth(AuthProvider auth) {
    _authProvider = auth;
  }

  /// Lista todos os usuários (admin)
  Future<void> loadUsers({
    String? role,
    String? search,
    int? limit,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userRepository.getUsers(
        role: role,
        search: search,
        limit: limit,
      );
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Erro ao carregar usuários';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Obtém usuário por ID
  Future<UserModel?> getUserById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedUser = await _userRepository.getUserById(id);
      _isLoading = false;
      notifyListeners();
      return _selectedUser;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Atualiza perfil do usuário atual
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? cep,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? houseNumber,
    String? avatarUrl,
    String? bannerUrl,
    String? pixKeyRandom,
    String? pixKeyPhone,
    String? pixKeyEmail,
    String? pixKeyCpf,
    double? residenceLat,
    double? residenceLng,
    String? residenceZoneId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _userRepository.updateProfile(
        userId: userId,
        name: name,
        phone: phone,
        cep: cep,
        state: state,
        city: city,
        neighborhood: neighborhood,
        street: street,
        houseNumber: houseNumber,
        avatarUrl: avatarUrl,
        bannerUrl: bannerUrl,
        pixKeyRandom: pixKeyRandom,
        pixKeyPhone: pixKeyPhone,
        pixKeyEmail: pixKeyEmail,
        pixKeyCpf: pixKeyCpf,
        residenceLat: residenceLat,
        residenceLng: residenceLng,
        residenceZoneId: residenceZoneId,
      );

      // Atualiza no AuthProvider
      _authProvider?.updateUser(updatedUser);

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Atualiza cargo do usuário (admin)
  Future<bool> updateUserRole(String userId, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _userRepository.updateUserRole(userId, role);
      
      // Atualiza na lista local
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove usuário (admin)
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepository.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Limpa usuário selecionado
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  /// Faz upload de uma imagem e retorna a URL
  Future<String?> uploadImage(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final imageUrl = await _userRepository.uploadImage(imageFile);
      _isLoading = false;
      notifyListeners();
      return imageUrl;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Erro ao fazer upload da imagem';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}

