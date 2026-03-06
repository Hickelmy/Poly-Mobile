import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/service_model.dart';

/// Repositório de serviços
class ServiceRepository {
  final ApiClient _apiClient;

  ServiceRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Lista serviços com filtros
  Future<List<ServiceModel>> getServices({
    String? serviceType,
    String? zoneId,
    bool? active,
    String? sort,
    int? limit,
    int? offset,
    String? providerId,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (serviceType != null) queryParams['service_type'] = serviceType;
      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (active != null) queryParams['active'] = active;
      if (sort != null) queryParams['sort'] = sort;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (providerId != null) queryParams['provider_id'] = providerId;
      if (userLat != null) queryParams['user_lat'] = userLat;
      if (userLng != null) queryParams['user_lng'] = userLng;

      final response = await _apiClient.get(
        ApiEndpoints.services,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      }
      
      if (data is Map && data.containsKey('data')) {
        final list = data['data'] as List;
        return list.map((json) => ServiceModel.fromJson(json)).toList();
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao listar serviços',
        details: e.toString(),
      );
    }
  }

  /// Obtém serviço por ID
  Future<ServiceModel> getServiceById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.serviceById(id));
      return ServiceModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao obter serviço',
        details: e.toString(),
      );
    }
  }

  /// Cria novo serviço
  Future<ServiceModel> createService({
    required String title,
    String? description,
    double? price,
    String priceType = 'servico',
    String? serviceType,
    List<String>? images,
    String? zoneId,
    double? lat,
    double? lng,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'priceType': priceType,
      };
      
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (serviceType != null) data['serviceType'] = serviceType;
      if (images != null) data['images'] = images;
      if (zoneId != null) data['zoneId'] = zoneId;
      if (lat != null) data['lat'] = lat;
      if (lng != null) data['lng'] = lng;

      final response = await _apiClient.post(
        ApiEndpoints.services,
        data: data,
      );
      return ServiceModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao criar serviço',
        details: e.toString(),
      );
    }
  }

  /// Atualiza serviço
  Future<ServiceModel> updateService(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.serviceById(id),
        data: data,
      );
      return ServiceModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao atualizar serviço',
        details: e.toString(),
      );
    }
  }

  /// Remove serviço
  Future<void> deleteService(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.serviceById(id));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao remover serviço',
        details: e.toString(),
      );
    }
  }

  /// Lista serviços do prestador
  Future<List<ServiceModel>> getProviderServices(String providerId) async {
    return getServices(providerId: providerId);
  }

  /// Ativa/desativa serviço
  Future<ServiceModel> toggleServiceActive(String id, bool active) async {
    return updateService(id, {'active': active});
  }
}

