import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/booking.dart';

class BookingService {
  BookingService._();

  static final BookingService instance = BookingService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<Booking> createBooking({
    required String tripId,
    required int numberOfSeats,
  }) async {
    final dynamic response = await _apiClient.post(
      '/bookings',
      authenticated: true,
      body: {'tripId': tripId, 'numberOfSeats': numberOfSeats},
    );

    final Map<String, dynamic> data = _extractData(
      response,
      errorMessage: 'Booking information is missing.',
    );

    return Booking.fromJson(data);
  }

  Future<List<Booking>> getMyBookings() async {
    final dynamic response = await _apiClient.get(
      '/bookings/me',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'Booking list is missing.');
    }

    return data
        .whereType<Map>()
        .map((item) => Booking.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Booking> getBookingById(String bookingId) async {
    final dynamic response = await _apiClient.get(
      '/bookings/$bookingId',
      authenticated: true,
    );

    final Map<String, dynamic> data = _extractData(
      response,
      errorMessage: 'Booking information is missing.',
    );

    return Booking.fromJson(data);
  }

  Future<Booking> cancelBooking(String bookingId) async {
    final dynamic response = await _apiClient.patch(
      '/bookings/$bookingId/cancel',
      authenticated: true,
    );

    final Map<String, dynamic> data = _extractData(
      response,
      errorMessage: 'Cancelled booking information is missing.',
    );

    return Booking.fromJson(data);
  }

  Map<String, dynamic> _extractData(
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

    return Map<String, dynamic>.from(data);
  }
}
