import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/payment.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<Payment> initiatePayment({
    required String bookingId,
    String method = 'SIMULATED',
  }) async {
    final dynamic response = await _apiClient.post(
      '/payments',
      authenticated: true,
      body: {'bookingId': bookingId, 'method': method},
    );

    return _extractPayment(response);
  }

  Future<Payment> simulatePayment({
    required String paymentId,
    required String result,
  }) async {
    if (result != 'SUCCESSFUL' && result != 'FAILED') {
      throw const ApiException(message: 'Invalid simulated payment result.');
    }

    final dynamic response = await _apiClient.patch(
      '/payments/$paymentId/simulate',
      authenticated: true,
      body: {'result': result},
    );

    return _extractPayment(response);
  }

  Future<Payment> getPaymentById(String paymentId) async {
    final dynamic response = await _apiClient.get(
      '/payments/$paymentId',
      authenticated: true,
    );

    return _extractPayment(response);
  }

  Future<List<Payment>> getPaymentsByBookingId(String bookingId) async {
    final dynamic response = await _apiClient.get(
      '/payments/booking/$bookingId',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'Payment list is missing.');
    }

    return data
        .whereType<Map>()
        .map((item) => Payment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Payment _extractPayment(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'Payment information is missing.');
    }

    return Payment.fromJson(Map<String, dynamic>.from(data));
  }
}
