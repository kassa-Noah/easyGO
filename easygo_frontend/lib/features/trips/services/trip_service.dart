import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/trip.dart';

class TripService {
  TripService._();

  static final TripService instance = TripService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<List<Trip>> searchTrips({
    required String originCity,
    required String destinationCity,
    required DateTime travelDate,
  }) async {
    final String date = _formatApiDate(travelDate);

    final String encodedOrigin = Uri.encodeQueryComponent(originCity.trim());

    final String encodedDestination = Uri.encodeQueryComponent(
      destinationCity.trim(),
    );

    final String path =
        '/search/trips'
        '?originCity=$encodedOrigin'
        '&destinationCity=$encodedDestination'
        '&travelDate=$date';

    final dynamic response = await _apiClient.get(path);

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid trip search response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'Trip search information is missing.');
    }

    return data
        .whereType<Map>()
        .map((item) => Trip.fromJson(Map<String, dynamic>.from(item)))
        .where((trip) => trip.id.isNotEmpty)
        .toList();
  }

  String _formatApiDate(DateTime date) {
    final String year = date.year.toString();

    final String month = date.month.toString().padLeft(2, '0');

    final String day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
