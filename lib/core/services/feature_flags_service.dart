import '../../core/network/api_client.dart';

class FeatureFlagsService {
  final ApiClient _apiClient;
  Map<String, bool> _flags = {};
  bool _isLoaded = false;

  FeatureFlagsService({required ApiClient apiClient}) : _apiClient = apiClient;

  bool get isLoaded => _isLoaded;
  Map<String, bool> get flags => Map.unmodifiable(_flags);

  /// Carrega todas as flags para o contexto dado
  Future<void> loadFlags({
    String? zoneId,
    String? city,
    String? state,
    String? userId,
    String? userRole,
  }) async {
    try {
      final params = <String, String>{};
      if (zoneId != null) params['zoneId'] = zoneId;
      if (city != null) params['city'] = city;
      if (state != null) params['state'] = state;
      if (userId != null) params['userId'] = userId;
      if (userRole != null) params['userRole'] = userRole;

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get(
        '/feature-flags/evaluate${queryString.isNotEmpty ? '?$queryString' : ''}',
      );

      if (response.data is Map<String, dynamic>) {
        _flags = (response.data as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value == true),
        );
      }

      _isLoaded = true;
    } catch (_) {
      // fail-open: tudo habilitado se houver erro
      _isLoaded = true;
    }
  }

  /// Verifica se uma feature está habilitada.
  /// Retorna true por padrão (fail-open).
  bool isEnabled(String key) {
    if (!_isLoaded) return true;
    return _flags[key] ?? true;
  }

  /// Verifica uma flag individual no servidor
  Future<bool> check(String key, {
    String? zoneId,
    String? city,
    String? state,
  }) async {
    try {
      final params = <String, String>{};
      if (zoneId != null) params['zoneId'] = zoneId;
      if (city != null) params['city'] = city;
      if (state != null) params['state'] = state;

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get(
        '/feature-flags/check/$key${queryString.isNotEmpty ? '?$queryString' : ''}',
      );

      if (response.data is Map<String, dynamic>) {
        return response.data['enabled'] == true;
      }
      return true;
    } catch (_) {
      return true;
    }
  }
}
