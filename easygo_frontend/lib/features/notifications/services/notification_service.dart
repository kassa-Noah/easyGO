import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/app_notification.dart';

/// Reads and updates the notifications addressed to the signed-in account.
///
/// Every endpoint is scoped by the backend to the authenticated user, so the
/// same service serves the customer app and the administrator console.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final ApiClient _apiClient = ApiClient.instance;

  /// The signed-in account's notifications, newest first as the API returns
  /// them.
  Future<List<AppNotification>> getMine() async {
    final dynamic response = await _apiClient.get(
      '/notifications/me',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'The notification list is missing.');
    }

    final List<AppNotification> notifications = <AppNotification>[];

    for (final dynamic item in data) {
      if (item is Map) {
        notifications.add(
          AppNotification.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    return notifications;
  }

  /// How many notifications are still unread.
  Future<int> getUnreadCount() async {
    final dynamic response = await _apiClient.get(
      '/notifications/unread-count',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'The unread count is missing.');
    }

    final dynamic count = data['unreadCount'];

    return count is num
        ? count.toInt()
        : int.tryParse('$count') ?? 0;
  }

  /// Marks every notification as read, returning how many were changed.
  Future<int> markAllAsRead() async {
    final dynamic response = await _apiClient.patch(
      '/notifications/read-all',
      authenticated: true,
    );

    if (response is! Map) {
      return 0;
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      return 0;
    }

    final dynamic updated = data['updatedCount'];

    return updated is num ? updated.toInt() : 0;
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch(
      '/notifications/$notificationId/read',
      authenticated: true,
    );
  }
}
