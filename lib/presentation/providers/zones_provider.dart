import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/zone_model.dart';
import '../../data/repositories/zone_repository.dart';

/// Provider de zonas
class ZonesProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final ZoneRepository _zoneRepository;

  List<ZoneModel> _zones = [];
  ZoneModel? _selectedZone;
  Map<String, dynamic>? _selectedZoneStats;
  bool _isLoading = false;
  String? _error;

  ZonesProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _zoneRepository = ZoneRepository(apiClient: _apiClient);
  }

  // Getters
  List<ZoneModel> get zones => _zones;
  List<ZoneModel> get activeZones => _zones.where((z) => z.active).toList();
  ZoneModel? get selectedZone => _selectedZone;
  Map<String, dynamic>? get selectedZoneStats => _selectedZoneStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carrega lista de zonas
  Future<void> loadZones({bool activeOnly = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _zones = await _zoneRepository.getZones(
        active: activeOnly ? true : null,
      );
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Erro ao carregar zonas';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega detalhes de uma zona
  Future<ZoneModel?> loadZoneDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedZone = await _zoneRepository.getZoneById(id);
      _isLoading = false;
      notifyListeners();
      return _selectedZone;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Carrega estatísticas da zona
  Future<void> loadZoneStats(String id) async {
    try {
      _selectedZoneStats = await _zoneRepository.getZoneStats(id);
      notifyListeners();
    } catch (_) {}
  }

  /// Cria nova zona (admin)
  Future<ZoneModel?> createZone({
    required String name,
    String? description,
    String color = '#14B8A6',
    Map<String, dynamic>? polygonGeojson,
    double? centerLat,
    double? centerLng,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final zone = await _zoneRepository.createZone(
        name: name,
        description: description,
        color: color,
        polygonGeojson: polygonGeojson,
        centerLat: centerLat,
        centerLng: centerLng,
      );

      _zones.insert(0, zone);
      _isLoading = false;
      notifyListeners();
      return zone;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Atualiza zona (admin)
  Future<bool> updateZone(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _zoneRepository.updateZone(id, data);
      
      final index = _zones.indexWhere((z) => z.id == id);
      if (index != -1) {
        _zones[index] = updated;
      }
      
      if (_selectedZone?.id == id) {
        _selectedZone = updated;
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

  /// Remove zona (admin)
  Future<bool> deleteZone(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _zoneRepository.deleteZone(id);
      
      _zones.removeWhere((z) => z.id == id);
      
      if (_selectedZone?.id == id) {
        _selectedZone = null;
        _selectedZoneStats = null;
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

  /// Ativa/desativa zona (admin)
  Future<bool> toggleActive(String id, bool active) async {
    try {
      final updated = await _zoneRepository.toggleZoneActive(id, active);
      
      final index = _zones.indexWhere((z) => z.id == id);
      if (index != -1) {
        _zones[index] = updated;
      }
      
      if (_selectedZone?.id == id) {
        _selectedZone = updated;
      }

      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Seleciona uma zona
  void selectZone(ZoneModel? zone) {
    _selectedZone = zone;
    _selectedZoneStats = null;
    notifyListeners();
    
    if (zone != null) {
      loadZoneStats(zone.id);
    }
  }

  /// Obtém zona por ID da lista local
  ZoneModel? getZoneById(String id) {
    try {
      return _zones.firstWhere((z) => z.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedZone() {
    _selectedZone = null;
    _selectedZoneStats = null;
    notifyListeners();
  }
}

