import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/location_service.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/zone_model.dart';
import '../../data/repositories/zone_repository.dart';
import '../../core/network/api_client.dart';

/// Provider para gerenciar a zona selecionada pelo usuário
class SelectedZoneProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final ZoneRepository _zoneRepository;
  final LocationService _locationService = LocationService();

  List<ZoneModel> _allZones = [];
  List<ZoneModel> _myPrivateZones = []; // Zonas privadas que o usuário tem acesso
  ZoneModel? _selectedZone;
  bool _isLoading = false;
  String? _error;

  SelectedZoneProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _zoneRepository = ZoneRepository(apiClient: _apiClient);
  }

  // Getters
  List<ZoneModel> get allZones => _allZones;
  List<ZoneModel> get myPrivateZones => _myPrivateZones;
  ZoneModel? get selectedZone => _selectedZone;
  String? get selectedZoneId => _selectedZone?.id;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Verifica se o usuário tem acesso a zonas privadas
  bool get hasPrivateZones => _myPrivateZones.isNotEmpty;

  /// Inicializa: carrega zonas e detecta zona padrão
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Carrega todas as zonas ativas
      _allZones = await _zoneRepository.getZones(active: true);

      // Tenta carregar zona salva
      final prefs = await SharedPreferences.getInstance();
      final savedZoneId = prefs.getString('selected_zone_id');

      if (savedZoneId != null) {
        final savedZone = _allZones.firstWhere(
          (z) => z.id == savedZoneId,
          orElse: () => _allZones.first,
        );
        _selectedZone = savedZone;
      } else {
        // Se não tem zona salva, tenta detectar pela localização
        await _detectZoneByLocation();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar zonas';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Detecta zona baseada na localização do usuário
  Future<void> _detectZoneByLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        // Se não conseguir localização, usa a primeira zona ou null
        _selectedZone = _allZones.isNotEmpty ? _allZones.first : null;
        return;
      }

      final lat = position.latitude;
      final lng = position.longitude;

      // Procura zona que contém o ponto
      for (var zone in _allZones) {
        if (zone.hasPolygon && _isPointInPolygon(lat, lng, zone.polygonGeojson!)) {
          _selectedZone = zone;
          await _saveSelectedZone(zone.id);
          return;
        }
      }

      // Se não encontrou por polígono, procura pela distância do centro
      ZoneModel? nearestZone;
      double? nearestDistance;

      for (var zone in _allZones) {
        if (zone.hasCenter) {
          final distance = _calculateDistance(
            lat,
            lng,
            zone.centerLat!,
            zone.centerLng!,
          );
          if (nearestDistance == null || distance < nearestDistance) {
            nearestDistance = distance;
            nearestZone = zone;
          }
        }
      }

      // Se encontrou uma zona próxima (menos de 5km), usa ela
      if (nearestZone != null && nearestDistance != null && nearestDistance < 5.0) {
        _selectedZone = nearestZone;
        await _saveSelectedZone(nearestZone.id);
      } else {
        // Usa a primeira zona disponível
        _selectedZone = _allZones.isNotEmpty ? _allZones.first : null;
      }
    } catch (e) {
      _selectedZone = _allZones.isNotEmpty ? _allZones.first : null;
    }
  }

  /// Verifica se um ponto está dentro de um polígono (GeoJSON)
  bool _isPointInPolygon(double lat, double lng, Map<String, dynamic> geojson) {
    try {
      final coordinates = geojson['coordinates'];
      if (coordinates == null || coordinates is! List) return false;

      // GeoJSON pode ter formato: [[[lng, lat], ...]] ou [[lng, lat], ...]
      List<List<dynamic>> polygon;
      if (coordinates[0] is List && coordinates[0][0] is List) {
        polygon = List<List<dynamic>>.from(coordinates[0]);
      } else {
        polygon = List<List<dynamic>>.from(coordinates);
      }

      if (polygon.isEmpty) return false;

      // Algoritmo ray casting
      bool inside = false;
      for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
        final xi = polygon[i][0] is num ? polygon[i][0].toDouble() : double.parse(polygon[i][0].toString());
        final yi = polygon[i][1] is num ? polygon[i][1].toDouble() : double.parse(polygon[i][1].toString());
        final xj = polygon[j][0] is num ? polygon[j][0].toDouble() : double.parse(polygon[j][0].toString());
        final yj = polygon[j][1] is num ? polygon[j][1].toDouble() : double.parse(polygon[j][1].toString());

        final intersect = ((yi > lng) != (yj > lng)) &&
            (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
      }

      return inside;
    } catch (e) {
      return false;
    }
  }

  /// Calcula distância em km entre dois pontos
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);

  /// Seleciona uma zona manualmente
  Future<void> selectZone(ZoneModel zone) async {
    _selectedZone = zone;
    await _saveSelectedZone(zone.id);
    notifyListeners();
  }

  /// Salva zona selecionada no SharedPreferences
  Future<void> _saveSelectedZone(String zoneId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_zone_id', zoneId);
  }

  /// Limpa zona selecionada
  Future<void> clearSelectedZone() async {
    _selectedZone = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_zone_id');
    notifyListeners();
  }

  /// Recarrega zonas e redetecta
  Future<void> refresh() async {
    await initialize();
  }

  /// Carrega zonas privadas que o usuário tem acesso
  Future<void> loadMyPrivateZones() async {
    try {
      _myPrivateZones = await _zoneRepository.getMyZones();
      notifyListeners();
    } catch (e) {
      // Ignora erro silenciosamente - usuário pode não estar logado
    }
  }

  /// Entra em uma zona usando código de acesso
  Future<({bool success, String message, ZoneModel? zone})> joinWithCode(String accessCode) async {
    if (accessCode.isEmpty) {
      return (success: false, message: 'Digite o código de acesso', zone: null);
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _zoneRepository.joinZoneWithCode(accessCode);
      
      final zone = result['zone'] != null 
          ? ZoneModel.fromJson(result['zone'] as Map<String, dynamic>)
          : null;
      
      if (zone != null) {
        // Adiciona à lista de zonas privadas se não existir
        if (!_myPrivateZones.any((z) => z.id == zone.id)) {
          _myPrivateZones.add(zone);
        }
        
        // Adiciona à lista geral se não existir
        if (!_allZones.any((z) => z.id == zone.id)) {
          _allZones.add(zone);
        }
        
        // Seleciona a zona automaticamente
        _selectedZone = zone;
        await _saveSelectedZone(zone.id);
      }

      _isLoading = false;
      notifyListeners();
      
      return (
        success: result['success'] == true,
        message: result['message'] as String? ?? 'Acesso concedido!',
        zone: zone,
      );
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return (success: false, message: e.message, zone: null);
    } catch (e) {
      _error = 'Erro ao entrar na zona';
      _isLoading = false;
      notifyListeners();
      return (success: false, message: 'Erro ao entrar na zona', zone: null);
    }
  }

  /// Sai de uma zona privada
  Future<bool> leaveZone(String zoneId) async {
    try {
      await _zoneRepository.leaveZone(zoneId);
      
      // Remove da lista de zonas privadas
      _myPrivateZones.removeWhere((z) => z.id == zoneId);
      
      // Se a zona selecionada for essa, limpa
      if (_selectedZone?.id == zoneId) {
        _selectedZone = null;
        await clearSelectedZone();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o usuário tem acesso a uma zona específica
  bool hasAccessTo(String zoneId) {
    // Busca na lista geral (já filtrada pelo backend baseado no acesso do usuário)
    return _allZones.any((z) => z.id == zoneId);
  }
}

