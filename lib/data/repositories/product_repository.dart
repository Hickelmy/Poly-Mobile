import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/product_model.dart';

/// Repositório de produtos
class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Lista produtos com filtros
  Future<List<ProductModel>> getProducts({
    String? category,
    String? condition,
    String? zoneId,
    bool? active,
    String? sort,
    int? limit,
    int? offset,
    String? sellerId,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (condition != null) queryParams['condition'] = condition;
      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (active != null) queryParams['active'] = active;
      if (sort != null) queryParams['sort'] = sort;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (sellerId != null) queryParams['seller_id'] = sellerId;
      if (userLat != null) queryParams['user_lat'] = userLat;
      if (userLng != null) queryParams['user_lng'] = userLng;

      final response = await _apiClient.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      
      if (data is Map && data.containsKey('data')) {
        final list = data['data'] as List;
        return list.map((json) => ProductModel.fromJson(json)).toList();
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao listar produtos',
        details: e.toString(),
      );
    }
  }

  /// Obtém produto por ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.productById(id));
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao obter produto',
        details: e.toString(),
      );
    }
  }

  /// Cria novo produto
  Future<ProductModel> createProduct({
    required String title,
    String? description,
    required double price,
    required int quantityAvailable,
    String? category,
    String? condition,
    String? unitType,
    List<String>? images,
    String? zoneId,
    double? lat,
    double? lng,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'price': price,
        'quantityAvailable': quantityAvailable,
      };
      
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      if (condition != null) data['condition'] = condition;
      if (unitType != null) data['unitType'] = unitType;
      if (images != null) data['images'] = images;
      if (zoneId != null) data['zoneId'] = zoneId;
      if (lat != null) data['lat'] = lat;
      if (lng != null) data['lng'] = lng;

      final response = await _apiClient.post(
        ApiEndpoints.products,
        data: data,
      );
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao criar produto',
        details: e.toString(),
      );
    }
  }

  /// Atualiza produto
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.productById(id),
        data: data,
      );
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao atualizar produto',
        details: e.toString(),
      );
    }
  }

  /// Remove produto
  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.productById(id));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao remover produto',
        details: e.toString(),
      );
    }
  }

  /// Lista produtos do vendedor
  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    return getProducts(sellerId: sellerId);
  }

  /// Ativa/desativa produto
  Future<ProductModel> toggleProductActive(String id, bool active) async {
    return updateProduct(id, {'active': active});
  }

  /// Atualiza quantidade disponível
  Future<ProductModel> updateQuantity(String id, int quantity) async {
    return updateProduct(id, {'quantityAvailable': quantity});
  }
}

