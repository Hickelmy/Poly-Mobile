import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';

/// Repositório de pagamentos
class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Cria um pagamento via Stripe
  /// Retorna o client_secret necessário para abrir o Stripe Payment Sheet
  Future<Map<String, dynamic>> createStripePayment({
    required double amount,
    String? productId,
    String? serviceId,
    String? projectId,
    String? productTitle,
    String? serviceTitle,
    String? projectTitle,
    int quantity = 1,
    String currency = 'brl',
  }) async {
    try {
      final data = <String, dynamic>{
        'amount': amount,
        'quantity': quantity,
        'currency': currency,
      };

      if (productId != null) data['product_id'] = productId;
      if (serviceId != null) data['service_id'] = serviceId;
      if (projectId != null) data['project_id'] = projectId;
      if (productTitle != null) data['product_title'] = productTitle;
      if (serviceTitle != null) data['service_title'] = serviceTitle;
      if (projectTitle != null) data['project_title'] = projectTitle;

      final response = await _apiClient.post(
        ApiEndpoints.createStripe,
        data: data,
      );

      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao criar pagamento',
        details: e.toString(),
      );
    }
  }

  /// Verifica o status de um pagamento
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.paymentStatus(paymentId),
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao verificar status do pagamento',
        details: e.toString(),
      );
    }
  }
}

