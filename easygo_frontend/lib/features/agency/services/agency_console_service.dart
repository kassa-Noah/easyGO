import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/agency_console.dart';

/// Reads the agency console. Every endpoint is scoped by the backend
/// to the agency the signed-in staff member belongs to.
class AgencyConsoleService {
  AgencyConsoleService._();

  static final AgencyConsoleService instance = AgencyConsoleService._();

  final ApiClient _apiClient = ApiClient.instance;

  StaffAgencyProfile? _cachedAgency;

  /// The agency the signed-in staff member belongs to.
  ///
  /// Cached for the session: several screens only need it to label themselves,
  /// and re-reading it for every rebuild would be wasteful. Pass `refresh: true`
  /// after the agency has been edited.
  Future<StaffAgencyProfile> getMyAgency({bool refresh = false}) async {
    final StaffAgencyProfile? cached = _cachedAgency;

    if (!refresh && cached != null) {
      return cached;
    }

    final dynamic response = await _apiClient.get(
      '/staff/agency',
      authenticated: true,
    );

    final StaffAgencyProfile profile = StaffAgencyProfile.fromJson(
      _extractData(response),
    );

    _cachedAgency = profile;

    return profile;
  }

  Future<AgencyDashboard> getDashboard() async {
    final dynamic response = await _apiClient.get(
      '/staff/dashboard',
      authenticated: true,
    );

    return AgencyDashboard.fromJson(_extractData(response));
  }

  Future<List<ConsoleTrip>> getTrips() async {
    final dynamic response = await _apiClient.get(
      '/staff/trips',
      authenticated: true,
    );

    return _toTrips(_extractList(response));
  }

  Future<List<ConsoleBooking>> getBookings() async {
    final dynamic response = await _apiClient.get(
      '/staff/bookings',
      authenticated: true,
    );

    return _toBookings(_extractList(response));
  }

  Future<List<ConsoleLuggage>> getLuggage() async {
    final dynamic response = await _apiClient.get(
      '/staff/luggage',
      authenticated: true,
    );

    return _toLuggage(_extractList(response));
  }

  Future<List<ConsoleParcel>> getParcels() async {
    final dynamic response = await _apiClient.get(
      '/staff/parcels',
      authenticated: true,
    );

    return _toParcels(_extractList(response));
  }

  /// Moves a booking to a terminal state.
  ///
  /// Only `CANCELLED` and `COMPLETED` are accepted: a booking is
  /// confirmed by a successful payment, never by hand.
  Future<ConsoleBooking> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final dynamic response = await _apiClient.patch(
      '/bookings/$bookingId/status',
      authenticated: true,
      body: {'status': status},
    );

    return ConsoleBooking.fromJson(_extractData(response));
  }

  /// Advances a piece of luggage along its operational status. The
  /// backend records a tracking event and computes the progress.
  Future<void> updateLuggageStatus({
    required String luggageId,
    required String status,
    String? location,
    String? description,
  }) async {
    await _apiClient.patch(
      '/luggage/$luggageId/status',
      authenticated: true,
      body: {
        'status': status,
        'location': ?location,
        'description': ?description,
      },
    );
  }

  /// Advances a parcel along its operational status.
  Future<void> updateParcelStatus({
    required String parcelId,
    required String status,
    String? location,
    String? description,
  }) async {
    await _apiClient.patch(
      '/parcels/$parcelId/status',
      authenticated: true,
      body: {
        'status': status,
        'location': ?location,
        'description': ?description,
      },
    );
  }

  /// Updates the agency the signed-in staff member belongs to.
  ///
  /// The API accepts a name, description, email, phone, logo URL and active
  /// flag. Branch addresses live on each branch, so they are not part of this.
  Future<void> updateAgency({
    required String agencyId,
    required String name,
    required String description,
    required String email,
    required String phone,
  }) async {
    await _apiClient.patch(
      '/agencies/$agencyId',
      authenticated: true,
      body: {
        'name': name,
        'description': description,
        'email': email,
        'phone': phone,
      },
    );
  }

  /// Routes the agency operates, used to schedule a trip.
  ///
  /// `/routes` is public and returns every active route on the platform, so the
  /// result is narrowed to the routes whose branches both belong to [agencyId].
  Future<List<ConsoleRoute>> getAgencyRoutes({
    required String agencyId,
  }) async {
    final dynamic response = await _apiClient.get('/routes');

    return _toRoutes(
      _extractList(response),
    ).where((ConsoleRoute route) => route.belongsTo(agencyId)).toList();
  }

  /// Schedules a trip against one of the agency's own routes.
  ///
  /// The API rejects a departure that is not in the future, an arrival that is
  /// not after the departure, and a route owned by another agency, so the
  /// caller only needs to surface the returned message.
  Future<ConsoleTrip> createTrip({
    required String agencyId,
    required String routeId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required double price,
    required int totalSeats,
  }) async {
    final dynamic response = await _apiClient.post(
      '/trips',
      authenticated: true,
      body: {
        'agencyId': agencyId,
        'routeId': routeId,
        'departureTime': departureTime.toUtc().toIso8601String(),
        'arrivalTime': arrivalTime.toUtc().toIso8601String(),
        'price': price,
        'totalSeats': totalSeats,
      },
    );

    return ConsoleTrip.fromJson(_extractData(response));
  }

  /// Updates a scheduled trip. Omitted fields are left untouched.
  Future<ConsoleTrip> updateTrip({
    required String tripId,
    DateTime? departureTime,
    DateTime? arrivalTime,
    double? price,
    int? totalSeats,
  }) async {
    final dynamic response = await _apiClient.patch(
      '/trips/$tripId',
      authenticated: true,
      body: {
        if (departureTime != null)
          'departureTime': departureTime.toUtc().toIso8601String(),
        if (arrivalTime != null)
          'arrivalTime': arrivalTime.toUtc().toIso8601String(),
        'price': ?price,
        'totalSeats': ?totalSeats,
      },
    );

    return ConsoleTrip.fromJson(_extractData(response));
  }

  /// Adds a branch to the agency.
  ///
  /// The backend requires coordinates on a new branch even though the app has
  /// no map to pick them from, so the caller supplies them and the form that
  /// collects them says so.
  Future<ConsoleBranch> createBranch({
    required String agencyId,
    required String name,
    required String city,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
  }) async {
    final dynamic response = await _apiClient.post(
      '/agencies/$agencyId/branches',
      authenticated: true,
      body: {
        'name': name,
        'city': city,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phone': ?phone,
      },
    );

    return ConsoleBranch.fromJson(_extractData(response));
  }

  /// Updates a branch that already belongs to the agency.
  ///
  /// Every field is optional, so the caller can send only what changed and
  /// leave the coordinates the API already holds untouched.
  Future<ConsoleBranch> updateBranch({
    required String agencyId,
    required String branchId,
    String? name,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
  }) async {
    final dynamic response = await _apiClient.patch(
      '/agencies/$agencyId/branches/$branchId',
      authenticated: true,
      body: {
        'name': ?name,
        'city': ?city,
        'address': ?address,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'phone': ?phone,
      },
    );

    return ConsoleBranch.fromJson(_extractData(response));
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'Agency information is missing.');
    }

    return Map<String, dynamic>.from(data);
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'The agency list is missing.');
    }

    return data;
  }
}

// The parameters are typed as lists on purpose: on a `dynamic`
// receiver Dart cannot infer the type argument of `map`, so the chain
// would produce a `List<dynamic>` and fail the cast at runtime.

List<ConsoleTrip> _toTrips(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => ConsoleTrip.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<ConsoleBooking> _toBookings(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => ConsoleBooking.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<ConsoleLuggage> _toLuggage(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => ConsoleLuggage.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<ConsoleParcel> _toParcels(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => ConsoleParcel.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<ConsoleRoute> _toRoutes(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => ConsoleRoute.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
