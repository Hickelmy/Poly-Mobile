/// Serviço para verificar conectividade de rede
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementação básica - pode ser expandida com connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // TODO: Implementar com connectivity_plus para verificação real
    // Por enquanto, assume que está conectado
    return true;
  }
}

