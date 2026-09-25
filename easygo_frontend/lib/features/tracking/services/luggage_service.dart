import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/tracking.dart';

class LuggageService {
  LuggageService._();

  static final LuggageService instance = LuggageService._();

  final ApiClient _apiClient = ApiClient.instance;

  /// Registers a piece of luggage against a booking.
  Future<Luggage> registerLuggage({
    required String bookingId,
    String? description,
    double? weightKg,
  }) async {
    final dynamic response = await _apiClient.post(
      '/luggage',
      authenticated: true,
      body: {
        'bookingId': bookingId,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'weightKg': ?weightKg,
      },
    );

    return _extractLuggage(
      response,
      errorMessage: 'Luggage information is missing.',
    );
  }

  Future<List<Luggage>> getMyLuggage() async {
    final dynamic response = await _apiClient.get(
      '/luggage/me',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'Luggage list is missing.');
    }

    return _toLuggageList(data);
  }

  /// Looks up luggage using the reference shown on the label.
  ///
  /// Throws an [ApiException] with status 404 when the reference
  /// is unknown, so the caller can distinguish "not found" from
  /// a genuine failure.
  Future<Luggage> trackLuggage(String trackingNumber) async {
    final String reference = Uri.encodeComponent(trackingNumber.trim());

    final dynamic response = await _apiClient.get(
      '/luggage/track/$reference',
      authenticated: true,
    );

    return _extractLuggage(
      response,
      errorMessage: 'Luggage tracking information is missing.',
    );
  }

  Future<Luggage> getLuggageById(String luggageId) async {
    final dynamic response = await _apiClient.get(
      '/luggage/$luggageId',
      authenticated: true,
    );

    return _extractLuggage(
      response,
      errorMessage: 'Luggage information is missing.',
    );
  }

  Luggage _extractLuggage(
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

    return Luggage.fromJson(Map<String, dynamic>.from(data));
  }
}

// The parameter is typed as a list on purpose: on a `dynamic`
// receiver Dart cannot infer the type argument of `map`, so the
// chain would produce a `List<dynamic>` and fail the cast to
// `List<Luggage>` at runtime.
List<Luggage> _toLuggageList(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => Luggage.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
