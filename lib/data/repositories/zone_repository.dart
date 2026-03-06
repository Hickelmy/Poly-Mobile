import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/zone_model.dart';

/// Repositório de zonas
class ZoneRepository {
  final ApiClient _apiClient;

  ZoneRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Lista zonas
  Future<List<ZoneModel>> getZones({
    bool? active,
    String? orderBy,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (active != null) queryParams['active'] = active;
      if (orderBy != null) queryParams['orderBy'] = orderBy;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        ApiEndpoints.zones,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => ZoneModel.fromJson(json)).toList();
      }
      
      if (data is Map && data.containsKey('data')) {
        final list = data['data'] as List;
        return list.map((json) => ZoneModel.fromJson(json)).toList();
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao listar zonas',
        details: e.toString(),
      );
    }
  }

  /// Obtém zona por ID
  Future<ZoneModel> getZoneById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.zoneById(id));
      return ZoneModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao obter zona',
        details: e.toString(),
      );
    }
  }

  /// Obtém estatísticas da zona
  Future<Map<String, dynamic>> getZoneStats(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.zoneStats(id));
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao obter estatísticas',
        details: e.toString(),
      );
    }
  }

  /// Cria nova zona (admin)
  Future<ZoneModel> createZone({
    required String name,
    String? description,
    String color = '#14B8A6',
    Map<String, dynamic>? polygonGeojson,
    double? centerLat,
    double? centerLng,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'color': color,
        'active': true,
      };
      
      if (description != null) data['description'] = description;
      if (polygonGeojson != null) data['polygonGeojson'] = polygonGeojson;
      if (centerLat != null) data['centerLat'] = centerLat;
      if (centerLng != null) data['centerLng'] = centerLng;

      final response = await _apiClient.post(
        ApiEndpoints.zones,
        data: data,
      );
      return ZoneModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao criar zona',
        details: e.toString(),
      );
    }
  }

  /// Atualiza zona (admin)
  Future<ZoneModel> updateZone(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.zoneById(id),
        data: data,
      );
      return ZoneModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao atualizar zona',
        details: e.toString(),
      );
    }
  }

  /// Remove zona (admin)
  Future<void> deleteZone(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.zoneById(id));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao remover zona',
        details: e.toString(),
      );
    }
  }

  /// Ativa/desativa zona (admin)
  Future<ZoneModel> toggleZoneActive(String id, bool active) async {
    return updateZone(id, {'active': active});
  }

  /// Entra em uma zona usando código de acesso
  Future<Map<String, dynamic>> joinZoneWithCode(String accessCode) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.joinZone,
        data: {'access_code': accessCode.toUpperCase()},
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao entrar na zona',
        details: e.toString(),
      );
    }
  }

  /// Lista zonas que o usuário tem acesso
  Future<List<ZoneModel>> getMyZones() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myZones);
      
      final data = response.data;
      if (data is List) {
        return data.map((json) => ZoneModel.fromJson(json)).toList();
      }
      
      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao listar suas zonas',
        details: e.toString(),
      );
    }
  }

  /// Sai de uma zona
  Future<void> leaveZone(String zoneId) async {
    try {
      await _apiClient.delete(ApiEndpoints.leaveZone(zoneId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao sair da zona',
        details: e.toString(),
      );
    }
  }
}

