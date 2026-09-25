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

  /// Notifications addressed to the signed-in administrator.
  Future<List<AdminNotification>> getNotifications() async {
    final dynamic response = await _apiClient.get(
      '/notifications/me',
      authenticated: true,
    );

    final List<AdminNotification> notifications = <AdminNotification>[];

    for (final dynamic item in _extractList(response)) {
      if (item is Map) {
        notifications.add(
          AdminNotification.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    return notifications;
  }

  /// How many notifications are still unread.
  Future<int> getUnreadNotificationCount() async {
    final dynamic response = await _apiClient.get(
      '/notifications/unread-count',
      authenticated: true,
    );

    final Map<String, dynamic> data = _extractData(response);

    return data['unreadCount'] is int
        ? data['unreadCount'] as int
        : int.tryParse('${data['unreadCount']}') ?? 0;
  }

  /// Marks every notification as read.
  Future<void> markAllNotificationsRead() async {
    await _apiClient.patch('/notifications/read-all', authenticated: true);
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
}
