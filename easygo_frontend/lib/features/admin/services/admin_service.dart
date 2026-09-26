import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/admin_console.dart';

/// Reads and manages the platform from the administrator console.
///
/// Every endpoint here is refused by the backend unless the signed-in account
/// carries the ADMIN role, so the screens do not need to police themselves.
class AdminService {
  AdminService._();

  static final AdminService instance = AdminService._();

  final ApiClient _apiClient = ApiClient.instance;

  /// Platform-wide counters.
  Future<AdminStatistics> getStatistics() async {
    final dynamic response = await _apiClient.get(
      '/admin/statistics',
      authenticated: true,
    );

    return AdminStatistics.fromJson(_extractData(response));
  }

  /// The landing page payload: counters plus the newest records.
  Future<AdminDashboard> getDashboard() async {
    final dynamic response = await _apiClient.get(
      '/admin/dashboard',
      authenticated: true,
    );

    return AdminDashboard.fromJson(_extractData(response));
  }

  /// Every account on the platform.
  Future<List<AdminAccount>> getUsers() async {
    final dynamic response = await _apiClient.get(
      '/users',
      authenticated: true,
    );

    final List<AdminAccount> accounts = <AdminAccount>[];

    for (final dynamic item in _extractList(response)) {
      if (item is Map) {
        accounts.add(
          AdminAccount.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    return accounts;
  }

  /// Enables or disables an account. The backend refuses an invalid value.
  Future<AdminAccount> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    final dynamic response = await _apiClient.patch(
      '/users/$userId/status',
      authenticated: true,
      body: {'isActive': isActive},
    );

    return AdminAccount.fromJson(_extractData(response));
  }

  /// Every agency on the platform, suspended ones included.
  ///
  /// The public `/agencies` directory is filtered to active agencies, which
  /// would hide a suspended agency from the console and make suspension a
  /// one-way door, so the admin-scoped endpoint is used instead.
  Future<List<AdminAgency>> getAgencies() async {
    final dynamic response = await _apiClient.get(
      '/admin/agencies',
      authenticated: true,
    );

    final List<AdminAgency> agencies = <AdminAgency>[];

    for (final dynamic item in _extractList(response)) {
      if (item is Map) {
        agencies.add(
          AdminAgency.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    return agencies;
  }

  /// Enables or disables an agency.
  ///
  /// The platform stores a single active flag, so this is the only state change
  /// an administrator can make to an agency; there is no approval workflow.
  Future<AdminAgency> updateAgencyStatus({
    required String agencyId,
    required bool isActive,
  }) async {
    final dynamic response = await _apiClient.patch(
      '/agencies/$agencyId',
      authenticated: true,
      body: {'isActive': isActive},
    );

    return AdminAgency.fromJson(_extractData(response));
  }

  /// The signed-in administrator's own account.
  Future<AdminAccount> getMyAccount() async {
    final dynamic response = await _apiClient.get(
      '/users/me',
      authenticated: true,
    );

    return AdminAccount.fromJson(_extractData(response));
  }

  /// Updates the signed-in administrator's own details.
  Future<AdminAccount> updateMyAccount({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final dynamic response = await _apiClient.patch(
      '/users/me',
      authenticated: true,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': ?phone,
      },
    );

    return AdminAccount.fromJson(_extractData(response));
  }

  /// Every trip on the platform.
  ///
  /// `/trips` is public and already returns the whole platform with the agency
  /// and route attached, so no admin-scoped variant is needed.
  Future<List<AdminTripRow>> getTrips() async {
    final dynamic response = await _apiClient.get('/trips');

    return _mapList(response, AdminTripRow.fromJson);
  }

  /// Every booking on the platform.
  Future<List<AdminBookingRow>> getAllBookings() async {
    final dynamic response = await _apiClient.get(
      '/admin/bookings',
      authenticated: true,
    );

    return _mapList(response, AdminBookingRow.fromJson);
  }

  /// Every piece of luggage on the platform.
  Future<List<AdminLuggageRow>> getAllLuggage() async {
    final dynamic response = await _apiClient.get(
      '/admin/luggage',
      authenticated: true,
    );

    return _mapList(response, AdminLuggageRow.fromJson);
  }

  /// Every payment on the platform.
  ///
  /// The booking comes with it, carrying the agency, the route and the
  /// traveller, so the monitor can say which journey was paid for and by whom
  /// rather than showing a bare transaction reference.
  Future<List<AdminPaymentRow>> getAllPayments() async {
    final dynamic response = await _apiClient.get(
      '/admin/payments',
      authenticated: true,
    );

    return _mapList(response, AdminPaymentRow.fromJson);
  }

  /// Every parcel on the platform.
  Future<List<AdminParcelRow>> getAllParcels() async {
    final dynamic response = await _apiClient.get(
      '/admin/parcels',
      authenticated: true,
    );

    return _mapList(response, AdminParcelRow.fromJson);
  }

  /// Every route, including the ones that are no longer active.
  ///
  /// The public `/routes` list is filtered to active routes, so retiring one
  /// would remove it from the only list that could bring it back. This goes
  /// through the admin endpoint instead.
  Future<List<AdminRoute>> getRoutes() async {
    final dynamic response = await _apiClient.get(
      '/admin/routes',
      authenticated: true,
    );

    return _mapList(response, AdminRoute.fromJson);
  }

  /// Every branch on the platform, with the agency that owns it.
  ///
  /// Routes join two branches by id, so the editor needs the ids and not just
  /// the cities. The admin agency list carries each agency's branches, which
  /// also keeps the branches of a suspended agency visible here.
  Future<List<AdminBranch>> getBranches() async {
    final dynamic response = await _apiClient.get(
      '/admin/agencies',
      authenticated: true,
    );

    final List<AdminBranch> branches = <AdminBranch>[];

    for (final dynamic item in _extractList(response)) {
      if (item is! Map) {
        continue;
      }

      final Map<String, dynamic> agency = Map<String, dynamic>.from(item);
      final dynamic rawBranches = agency['branches'];

      if (rawBranches is! List) {
        continue;
      }

      for (final dynamic rawBranch in rawBranches) {
        if (rawBranch is! Map) {
          continue;
        }

        final AdminBranch? branch = AdminBranch.fromAgencyJson(
          agency,
          Map<String, dynamic>.from(rawBranch),
        );

        if (branch != null) {
          branches.add(branch);
        }
      }
    }

    branches.sort((AdminBranch a, AdminBranch b) => a.label.compareTo(b.label));

    return branches;
  }

  /// Creates a route between two branches.
  ///
  /// The backend rejects two identical branches, a branch that does not exist
  /// and a pair that already has a route, so the caller only needs to surface
  /// the message it returns.
  Future<AdminRoute> createRoute({
    required String originBranchId,
    required String destinationBranchId,
    required double baseFare,
    double? distanceKm,
    int? estimatedDurationMinutes,
  }) async {
    final dynamic response = await _apiClient.post(
      '/routes',
      authenticated: true,
      body: {
        'originBranchId': originBranchId,
        'destinationBranchId': destinationBranchId,
        'baseFare': baseFare,
        'distanceKm': ?distanceKm,
        'estimatedDurationMinutes': ?estimatedDurationMinutes,
      },
    );

    return AdminRoute.fromJson(_extractData(response));
  }

  /// Updates a route. Omitted fields are left as they are.
  Future<AdminRoute> updateRoute({
    required String routeId,
    String? originBranchId,
    String? destinationBranchId,
    double? baseFare,
    double? distanceKm,
    int? estimatedDurationMinutes,
    bool? isActive,
  }) async {
    final dynamic response = await _apiClient.patch(
      '/routes/$routeId',
      authenticated: true,
      body: {
        'originBranchId': ?originBranchId,
        'destinationBranchId': ?destinationBranchId,
        'baseFare': ?baseFare,
        'distanceKm': ?distanceKm,
        'estimatedDurationMinutes': ?estimatedDurationMinutes,
        'isActive': ?isActive,
      },
    );

    return AdminRoute.fromJson(_extractData(response));
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(
        message: 'The administrator data is missing.',
      );
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
      throw const ApiException(
        message: 'The administrator list is missing.',
      );
    }

    return data;
  }

  /// Maps a list response through a row factory.
  ///
  /// The list parameter is typed rather than left dynamic on purpose: on a
  /// dynamic receiver Dart cannot infer the type argument of `map`, and the
  /// resulting `List<dynamic>` fails its cast at runtime.
  List<T> _mapList<T>(
    dynamic response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final List<T> rows = <T>[];

    for (final dynamic item in _extractList(response)) {
      if (item is Map) {
        rows.add(fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return rows;
  }
}
