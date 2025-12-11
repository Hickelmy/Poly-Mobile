import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Repositório de usuários
class UserRepository {
  final ApiClient _apiClient;

  UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Obtém usuário por ID
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userById(id));
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao obter usuário',
        details: e.toString(),
      );
    }
  }

  /// Lista todos os usuários (admin)
  Future<List<UserModel>> getUsers({
    String? role,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null) queryParams['role'] = role;
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        ApiEndpoints.users,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      
      // Se retornar objeto com lista
      if (data is Map && data.containsKey('data')) {
        final list = data['data'] as List;
        return list.map((json) => UserModel.fromJson(json)).toList();
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao listar usuários',
        details: e.toString(),
      );
    }
  }

  /// Atualiza dados do usuário
  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.userById(id),
        data: data,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao atualizar usuário',
        details: e.toString(),
      );
    }
  }

  /// Atualiza o perfil do usuário atual
  Future<UserModel> updateProfile({
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
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (cep != null) data['cep'] = cep;
    if (state != null) data['state'] = state;
    if (city != null) data['city'] = city;
    if (neighborhood != null) data['neighborhood'] = neighborhood;
    if (street != null) data['street'] = street;
    if (houseNumber != null) data['houseNumber'] = houseNumber;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (bannerUrl != null) data['bannerUrl'] = bannerUrl;
    if (pixKeyRandom != null) data['pixKeyRandom'] = pixKeyRandom;
    if (pixKeyPhone != null) data['pixKeyPhone'] = pixKeyPhone;
    if (pixKeyEmail != null) data['pixKeyEmail'] = pixKeyEmail;
    if (pixKeyCpf != null) data['pixKeyCpf'] = pixKeyCpf;
    if (residenceLat != null) data['residenceLat'] = residenceLat;
    if (residenceLng != null) data['residenceLng'] = residenceLng;
    if (residenceZoneId != null) data['residenceZoneId'] = residenceZoneId;

    return updateUser(userId, data);
  }

  /// Atualiza o cargo do usuário (admin)
  Future<UserModel> updateUserRole(String userId, String role) async {
    return updateUser(userId, {'role': role});
  }

  /// Remove usuário
  Future<void> deleteUser(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.userById(id));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao remover usuário',
        details: e.toString(),
      );
    }
  }
}

