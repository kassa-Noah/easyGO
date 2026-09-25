import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/tracking.dart';

class ParcelService {
  ParcelService._();

  static final ParcelService instance = ParcelService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<Parcel> createParcel({
    required String description,
    required String recipientName,
    required String recipientPhone,
    required String originBranchId,
    required String destinationBranchId,
    double? weightKg,
    String? tripId,
    String? recipientUserId,
  }) async {
    final dynamic response = await _apiClient.post(
      '/parcels',
      authenticated: true,
      body: {
        'description': description.trim(),
        'recipientName': recipientName.trim(),
        'recipientPhone': recipientPhone.trim(),
        'originBranchId': originBranchId,
        'destinationBranchId': destinationBranchId,
        'weightKg': ?weightKg,
        'tripId': ?tripId,
        'recipientUserId': ?recipientUserId,
      },
    );

    return _extractParcel(
      response,
      errorMessage: 'Parcel information is missing.',
    );
  }

  Future<List<Parcel>> getMyParcels() async {
    final dynamic response = await _apiClient.get(
      '/parcels/me',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'Parcel list is missing.');
    }

    return data
        .whereType<Map>()
        .map((item) => Parcel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Looks up a parcel using its tracking reference.
  ///
  /// Throws an [ApiException] with status 404 when the reference
  /// is unknown.
  Future<Parcel> trackParcel(String trackingNumber) async {
    final String reference = Uri.encodeComponent(trackingNumber.trim());

    final dynamic response = await _apiClient.get(
      '/parcels/track/$reference',
      authenticated: true,
    );

    return _extractParcel(
      response,
      errorMessage: 'Parcel tracking information is missing.',
    );
  }

  Future<Parcel> getParcelById(String parcelId) async {
    final dynamic response = await _apiClient.get(
      '/parcels/$parcelId',
      authenticated: true,
    );

    return _extractParcel(
      response,
      errorMessage: 'Parcel information is missing.',
    );
  }

  Parcel _extractParcel(
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

    return Parcel.fromJson(Map<String, dynamic>.from(data));
  }
}
