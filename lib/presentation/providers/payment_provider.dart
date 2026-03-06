import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../../data/repositories/payment_repository.dart';

/// Provider de pagamentos
class PaymentProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final PaymentRepository _paymentRepository;

  bool _isLoading = false;
  String? _error;

  PaymentProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _paymentRepository = PaymentRepository(apiClient: _apiClient);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cria um pagamento via Stripe
  Future<Map<String, dynamic>?> createStripePayment({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentRepository.createStripePayment(
        amount: amount,
        productId: productId,
        serviceId: serviceId,
        projectId: projectId,
        productTitle: productTitle,
        serviceTitle: serviceTitle,
        projectTitle: projectTitle,
        quantity: quantity,
        currency: currency,
      );

      _isLoading = false;
      notifyListeners();
      return result;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Erro ao criar pagamento';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Verifica o status de um pagamento
  Future<Map<String, dynamic>?> checkPaymentStatus(String paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentRepository.checkPaymentStatus(paymentId);
      _isLoading = false;
      notifyListeners();
      return result;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Erro ao verificar status do pagamento';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}

