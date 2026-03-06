import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// Provider de produtos
class ProductsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final ProductRepository _productRepository;

  List<ProductModel> _products = [];
  List<ProductModel> _sellerProducts = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  // Filtros
  String? _categoryFilter;
  String? _conditionFilter;
  String _sortBy = 'proximity'; // Padrão: ordenar por proximidade
  
  // Localização do usuário para ordenação por proximidade
  double? _userLat;
  double? _userLng;

  ProductsProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _productRepository = ProductRepository(apiClient: _apiClient);
  }

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get sellerProducts => _sellerProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get categoryFilter => _categoryFilter;
  String? get conditionFilter => _conditionFilter;
  String get sortBy => _sortBy;
  double? get userLat => _userLat;
  double? get userLng => _userLng;

  /// Define a localização do usuário para ordenação por proximidade
  void setUserLocation(double? lat, double? lng) {
    _userLat = lat;
    _userLng = lng;
  }

  /// Carrega lista de produtos ordenados por proximidade
  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    if (refresh) _products = [];
    notifyListeners();

    try {
      _products = await _productRepository.getProducts(
        category: _categoryFilter,
        condition: _conditionFilter,
        sort: _sortBy,
        active: true,
        userLat: _userLat,
        userLng: _userLng,
      );
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Erro ao carregar produtos';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega detalhes de um produto
  Future<ProductModel?> loadProductDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await _productRepository.getProductById(id);
      _isLoading = false;
      notifyListeners();
      return _selectedProduct;
    } on NotFoundException {
      _error = 'Produto não encontrado';
      _isLoading = false;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Carrega produtos do vendedor
  Future<void> loadSellerProducts(String sellerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sellerProducts = await _productRepository.getSellerProducts(sellerId);
    } on AppException catch (e) {
      _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cria novo produto
  Future<ProductModel?> createProduct({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _productRepository.createProduct(
        title: title,
        description: description,
        price: price,
        quantityAvailable: quantityAvailable,
        category: category,
        condition: condition,
        unitType: unitType,
        images: images,
        zoneId: zoneId,
        lat: lat,
        lng: lng,
      );

      _products.insert(0, product);
      _sellerProducts.insert(0, product);
      _isLoading = false;
      notifyListeners();
      return product;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Atualiza produto
  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _productRepository.updateProduct(id, data);
      
      // Atualiza nas listas
      _updateInList(_products, updated);
      _updateInList(_sellerProducts, updated);
      
      if (_selectedProduct?.id == id) {
        _selectedProduct = updated;
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

  /// Remove produto
  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _productRepository.deleteProduct(id);
      
      _products.removeWhere((p) => p.id == id);
      _sellerProducts.removeWhere((p) => p.id == id);
      
      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
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

  /// Ativa/desativa produto
  Future<bool> toggleActive(String id, bool active) async {
    try {
      final updated = await _productRepository.toggleProductActive(id, active);
      
      _updateInList(_products, updated);
      _updateInList(_sellerProducts, updated);
      
      if (_selectedProduct?.id == id) {
        _selectedProduct = updated;
      }

      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  void _updateInList(List<ProductModel> list, ProductModel updated) {
    final index = list.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      list[index] = updated;
    }
  }

  /// Define filtros
  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    loadProducts(refresh: true);
  }

  void setConditionFilter(String? condition) {
    _conditionFilter = condition;
    loadProducts(refresh: true);
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    loadProducts(refresh: true);
  }

  void clearFilters() {
    _categoryFilter = null;
    _conditionFilter = null;
    _sortBy = 'proximity';
    loadProducts(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}

