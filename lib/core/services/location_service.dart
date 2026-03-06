import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Status detalhado da localização
enum LocationStatus {
  granted,           // Permissão concedida e serviço habilitado
  permissionDenied,  // Permissão negada pelo usuário
  serviceDisabled,   // Serviço de localização desabilitado
  error,             // Erro desconhecido
}

/// Serviço para obter localização do usuário
class LocationService {
  /// Verifica e solicita permissões de localização (em tempo real)
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Verifica se tem permissão de localização
  Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Verifica se o serviço de localização está habilitado
  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Abre as configurações de localização do dispositivo
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Abre as configurações do app para permissões
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Verifica o status completo da localização
  Future<LocationStatus> checkLocationStatus() async {
    try {
      // Verifica permissão
      final hasPerm = await hasPermission();
      if (!hasPerm) {
        final granted = await requestPermission();
        if (!granted) {
          return LocationStatus.permissionDenied;
        }
      }

      // Verifica se o serviço está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationStatus.serviceDisabled;
      }

      return LocationStatus.granted;
    } catch (e) {
      return LocationStatus.error;
    }
  }

  /// Obtém a localização atual do usuário
  Future<Position?> getCurrentLocation() async {
    try {
      // Verifica se tem permissão
      final hasPerm = await hasPermission();
      if (!hasPerm) {
        final granted = await requestPermission();
        if (!granted) {
          return null;
        }
      }

      // Verifica se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Obtém a localização
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtém a última localização conhecida (mais rápido)
  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }
}

