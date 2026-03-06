import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';

/// Provider de serviços
class ServicesProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final ServiceRepository _serviceRepository;

  List<ServiceModel> _services = [];
  List<ServiceModel> _providerServices = [];
  ServiceModel? _selectedService;
  bool _isLoading = false;
  String? _error;

  // Filtros
  String? _serviceTypeFilter;
  String _sortBy = 'proximity'; // Padrão: ordenar por proximidade
  
  // Localização do usuário para ordenação por proximidade
  double? _userLat;
  double? _userLng;

  ServicesProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _serviceRepository = ServiceRepository(apiClient: _apiClient);
  }

  // Getters
  List<ServiceModel> get services => _services;
  List<ServiceModel> get providerServices => _providerServices;
  ServiceModel? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get serviceTypeFilter => _serviceTypeFilter;
  String get sortBy => _sortBy;
  double? get userLat => _userLat;
  double? get userLng => _userLng;

  /// Define a localização do usuário para ordenação por proximidade
  void setUserLocation(double? lat, double? lng) {
    _userLat = lat;
    _userLng = lng;
  }

  /// Carrega lista de serviços ordenados por proximidade
  Future<void> loadServices({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    if (refresh) _services = [];
    notifyListeners();

    try {
      _services = await _serviceRepository.getServices(
        serviceType: _serviceTypeFilter,
        sort: _sortBy,
        active: true,
        userLat: _userLat,
        userLng: _userLng,
      );
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Erro ao carregar serviços';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega detalhes de um serviço
  Future<ServiceModel?> loadServiceDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedService = await _serviceRepository.getServiceById(id);
      _isLoading = false;
      notifyListeners();
      return _selectedService;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Carrega serviços do prestador
  Future<void> loadProviderServices(String providerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _providerServices = await _serviceRepository.getProviderServices(providerId);
    } on AppException catch (e) {
      _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cria novo serviço
  Future<ServiceModel?> createService({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = await _serviceRepository.createService(
        title: title,
        description: description,
        price: price,
        priceType: priceType,
        serviceType: serviceType,
        images: images,
        zoneId: zoneId,
        lat: lat,
        lng: lng,
      );

      _services.insert(0, service);
      _providerServices.insert(0, service);
      _isLoading = false;
      notifyListeners();
      return service;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Atualiza serviço
  Future<bool> updateService(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _serviceRepository.updateService(id, data);
      
      _updateInList(_services, updated);
      _updateInList(_providerServices, updated);
      
      if (_selectedService?.id == id) {
        _selectedService = updated;
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

  /// Remove serviço
  Future<bool> deleteService(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceRepository.deleteService(id);
      
      _services.removeWhere((s) => s.id == id);
      _providerServices.removeWhere((s) => s.id == id);
      
      if (_selectedService?.id == id) {
        _selectedService = null;
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

  /// Ativa/desativa serviço
  Future<bool> toggleActive(String id, bool active) async {
    try {
      final updated = await _serviceRepository.toggleServiceActive(id, active);
      
      _updateInList(_services, updated);
      _updateInList(_providerServices, updated);
      
      if (_selectedService?.id == id) {
        _selectedService = updated;
      }

      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  void _updateInList(List<ServiceModel> list, ServiceModel updated) {
    final index = list.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      list[index] = updated;
    }
  }

  /// Define filtros
  void setServiceTypeFilter(String? type) {
    _serviceTypeFilter = type;
    loadServices(refresh: true);
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    loadServices(refresh: true);
  }

  void clearFilters() {
    _serviceTypeFilter = null;
    _sortBy = 'proximity';
    loadServices(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedService() {
    _selectedService = null;
    notifyListeners();
  }
}

