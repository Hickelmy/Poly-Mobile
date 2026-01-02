import 'dart:io';

/// Endpoints da API POLYS Backend (NestJS)
class ApiEndpoints {
  ApiEndpoints._();

  /// Prefixo da API (ex: '/api' se o backend usar)
  /// Pode ser configurado via variável de ambiente API_PREFIX
  static String get apiPrefix {
    const prefix = String.fromEnvironment('API_PREFIX');
    return prefix.isNotEmpty ? prefix : '';
  }

  /// URL base da API - configurar via variável de ambiente ou .env
  /// No Android, usa 10.0.2.2 para acessar localhost da máquina host
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Se estiver rodando no Android, usa 10.0.2.2 para acessar localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001';
    }

    // Para outras plataformas, usa localhost
    return 'http://localhost:3001';
  }

  /// Helper para adicionar prefixo aos endpoints
  static String _endpoint(String path) {
    return '$apiPrefix$path';
  }

  // ============ AUTH ============
  static String get login => _endpoint('/auth/login');
  static String get register => _endpoint('/auth/register');
  static String get refreshToken => _endpoint('/auth/refresh');
  static String get logout => _endpoint('/auth/logout');

  // ============ USERS ============
  static String get users => _endpoint('/users');
  static String get currentUser => _endpoint('/users/me');
  static String userById(String id) => _endpoint('/users/$id');

  // ============ PROJECTS ============
  static String get projects => _endpoint('/projects');
  static String projectById(String id) => _endpoint('/projects/$id');

  // ============ PROJECT VOTES ============
  static String get projectVotes => _endpoint('/project-votes');

  // ============ PROJECT PAYMENTS ============
  static String get projectPayments => _endpoint('/project-payments');
  static String projectPaymentById(String id) =>
      _endpoint('/project-payments/$id');

  // ============ PRODUCTS ============
  static String get products => _endpoint('/products');
  static String productById(String id) => _endpoint('/products/$id');

  // ============ SERVICES ============
  static String get services => _endpoint('/services');
  static String serviceById(String id) => _endpoint('/services/$id');

  // ============ ZONES ============
  static String get zones => _endpoint('/zones');
  static String zoneById(String id) => _endpoint('/zones/$id');
  static String zoneStats(String id) => _endpoint('/zones/$id/stats');

  // ============ SETTINGS ============
  static String get settings => _endpoint('/settings');

  // ============ PAYMENT GATEWAY ============
  static String get createPix => _endpoint('/payment-gateway/create-pix');
  static String get generateQrCode =>
      _endpoint('/payment-gateway/generate-qrcode');
  static String paymentStatus(String id) =>
      _endpoint('/payment-gateway/status/$id');

  // ============ NEWS ============
  static String get news => _endpoint('/news');
  static String newsById(String id) => _endpoint('/news/$id');
  static String newsLike(String id) => _endpoint('/news/$id/like');
  static String newsComments(String id) => _endpoint('/news/$id/comments');
  static String newsReport(String id) => _endpoint('/news/$id/report');
}
