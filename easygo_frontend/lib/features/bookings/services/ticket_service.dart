import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/booking.dart';

class TicketService {
  TicketService._();

  static final TicketService instance = TicketService._();

  final ApiClient _apiClient = ApiClient.instance;

  /// Generates the digital ticket for a confirmed booking.
  ///
  /// The backend only issues a ticket once the booking is
  /// CONFIRMED and has a SUCCESSFUL payment. It answers with
  /// 409 when a ticket already exists for the booking.
  Future<BookingTicket> generateTicket(String bookingId) async {
    final dynamic response = await _apiClient.post(
      '/tickets',
      authenticated: true,
      body: {'bookingId': bookingId},
    );

    return _extractTicket(
      response,
      errorMessage: 'Ticket information is missing.',
    );
  }

  Future<BookingTicket> getTicketByBookingId(String bookingId) async {
    final dynamic response = await _apiClient.get(
      '/tickets/booking/$bookingId',
      authenticated: true,
    );

    return _extractTicket(
      response,
      errorMessage: 'Ticket information is missing.',
    );
  }

  Future<List<BookingTicket>> getMyTickets() async {
    final dynamic response = await _apiClient.get(
      '/tickets/me',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'Ticket list is missing.');
    }

    return data
        .whereType<Map>()
        .map((item) => BookingTicket.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  BookingTicket _extractTicket(
    dynamic response, {
    required String errorMessage,
  }) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw ApiException(message: errorMessage);
    }

    return BookingTicket.fromJson(Map<String, dynamic>.from(data));
  }
}
