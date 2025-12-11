/// Endpoints da API POLYS Backend (NestJS)
class ApiEndpoints {
  ApiEndpoints._();
  
  /// URL base da API - configurar via variável de ambiente ou .env
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );
  
  // ============ AUTH ============
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  // ============ USERS ============
  static const String users = '/users';
  static const String currentUser = '/users/me';
  static String userById(String id) => '/users/$id';
  
  // ============ PROJECTS ============
  static const String projects = '/projects';
  static String projectById(String id) => '/projects/$id';
  
  // ============ PROJECT VOTES ============
  static const String projectVotes = '/project-votes';
  
  // ============ PROJECT PAYMENTS ============
  static const String projectPayments = '/project-payments';
  static String projectPaymentById(String id) => '/project-payments/$id';
  
  // ============ PRODUCTS ============
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  
  // ============ SERVICES ============
  static const String services = '/services';
  static String serviceById(String id) => '/services/$id';
  
  // ============ ZONES ============
  static const String zones = '/zones';
  static String zoneById(String id) => '/zones/$id';
  static String zoneStats(String id) => '/zones/$id/stats';
  
  // ============ SETTINGS ============
  static const String settings = '/settings';
  
  // ============ PAYMENT GATEWAY ============
  static const String createPix = '/payment-gateway/create-pix';
  static const String generateQrCode = '/payment-gateway/generate-qrcode';
  static String paymentStatus(String id) => '/payment-gateway/status/$id';
  
  // ============ NEWS ============
  static const String news = '/news';
  static String newsById(String id) => '/news/$id';
  static String newsLike(String id) => '/news/$id/like';
  static String newsComments(String id) => '/news/$id/comments';
  static String newsReport(String id) => '/news/$id/report';
}

