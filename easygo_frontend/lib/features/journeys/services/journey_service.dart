import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/journey.dart';

class JourneyService {
  JourneyService._();

  static final JourneyService instance = JourneyService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<List<Journey>> getMyJourneys() async {
    final dynamic response = await _apiClient.get(
      '/journeys/me',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'Journey list is missing.');
    }

    return data
        .whereType<Map>()
        .map((item) => Journey.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Journey> getJourneyById(String journeyId) async {
    final dynamic response = await _apiClient.get(
      '/journeys/$journeyId',
      authenticated: true,
    );

    return _extractJourney(response);
  }

  Future<Journey> createJourney({
    required String bookingId,
    required String pickupAddress,
    required String destinationAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
  }) async {
    final Map<String, dynamic> body = {
      'bookingId': bookingId,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
    };

    if (pickupLatitude != null) {
      body['pickupLatitude'] = pickupLatitude;
    }

    if (pickupLongitude != null) {
      body['pickupLongitude'] = pickupLongitude;
    }

    if (destinationLatitude != null) {
      body['destinationLatitude'] = destinationLatitude;
    }

    if (destinationLongitude != null) {
      body['destinationLongitude'] = destinationLongitude;
    }

    final dynamic response = await _apiClient.post(
      '/journeys',
      authenticated: true,
      body: body,
    );

    return _extractJourney(response);
  }

  Journey _extractJourney(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'Journey information is missing.');
    }

    return Journey.fromJson(Map<String, dynamic>.from(data));
  }
}
