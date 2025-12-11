import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/app_settings_model.dart';

/// Provider de configurações do app
class SettingsProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  AppSettingsModel? _settings;
  bool _isLoading = false;
  String? _error;

  SettingsProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  // Getters
  AppSettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isMaintenanceMode => _settings?.maintenanceMode ?? false;
  bool get allowRegistrations => _settings?.allowRegistrations ?? true;
  double get platformFeePercent => _settings?.platformFeePercent ?? 5.0;

  /// Carrega configurações do app
  Future<void> loadSettings() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.settings);
      _settings = AppSettingsModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      _error = e.message;
      // Usa configurações padrão em caso de erro
      _settings = AppSettingsModel.defaults();
    } catch (e) {
      _error = 'Erro ao carregar configurações';
      _settings = AppSettingsModel.defaults();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Atualiza configurações (admin)
  Future<bool> updateSettings(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.patch(
        ApiEndpoints.settings,
        data: data,
      );
      _settings = AppSettingsModel.fromJson(response.data as Map<String, dynamic>);
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

  /// Ativa/desativa modo de manutenção
  Future<bool> toggleMaintenanceMode(bool enabled) async {
    return updateSettings({'maintenanceMode': enabled});
  }

  /// Ativa/desativa cadastros
  Future<bool> toggleRegistrations(bool enabled) async {
    return updateSettings({'allowRegistrations': enabled});
  }

  /// Atualiza taxa da plataforma
  Future<bool> updatePlatformFee(double percent) async {
    return updateSettings({'platformFeePercent': percent});
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

