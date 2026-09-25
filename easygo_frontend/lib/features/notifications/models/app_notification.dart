import 'package:flutter/material.dart';

/// A notification delivered to the signed-in account.
///
/// Notifications are addressed to a user, not to a role, so the customer app and
/// the administrator console read the same endpoint and share this model.

DateTime? _toNullableDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}

/// The stored notification categories.
///
/// The API keeps eight of them; the interface groups them into the three
/// headings a reader actually scans for.
const Map<String, String> _groupByType = <String, String>{
  'BOOKING': 'Journey',
  'PAYMENT': 'Journey',
  'TICKET': 'Journey',
  'TAXI': 'Journey',
  'TRIP': 'Journey',
  'LUGGAGE': 'Tracking',
  'PARCEL': 'Tracking',
  'SYSTEM': 'System',
};

const Map<String, IconData> _iconByType = <String, IconData>{
  'BOOKING': Icons.confirmation_number_outlined,
  'PAYMENT': Icons.account_balance_wallet_outlined,
  'TICKET': Icons.receipt_long_outlined,
  'TAXI': Icons.local_taxi_outlined,
  'TRIP': Icons.directions_bus_outlined,
  'LUGGAGE': Icons.luggage_outlined,
  'PARCEL': Icons.inventory_2_outlined,
  'SYSTEM': Icons.info_outline,
};

/// The groups the notification lists filter by, in display order.
const List<String> notificationGroups = <String>[
  'Journey',
  'Tracking',
  'System',
];

class AppNotification {
  final String id;
  final String title;
  final String message;

  /// One of BOOKING, PAYMENT, TICKET, TAXI, TRIP, LUGGAGE, PARCEL or SYSTEM.
  final String type;

  /// UNREAD or READ. The API stores a status, not a boolean.
  final String status;

  final DateTime? createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNREAD',
      createdAt: _toNullableDateTime(json['createdAt']),
      readAt: _toNullableDateTime(json['readAt']),
    );
  }

  bool get isRead => status == 'READ';

  /// The heading this notification belongs under.
  String get groupLabel => _groupByType[type] ?? 'System';

  IconData get icon => _iconByType[type] ?? Icons.notifications_outlined;

  /// A short, human age such as `10 min ago`, falling back to the date once the
  /// notification is more than a week old.
  String ageLabel({DateTime? now}) {
    final DateTime? created = createdAt;

    if (created == null) {
      return '';
    }

    final Duration elapsed = (now ?? DateTime.now()).difference(created);

    if (elapsed.isNegative || elapsed.inMinutes < 1) {
      return 'Just now';
    }

    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} min ago';
    }

    if (elapsed.inHours < 24) {
      return '${elapsed.inHours} h ago';
    }

    if (elapsed.inDays == 1) {
      return 'Yesterday';
    }

    if (elapsed.inDays < 7) {
      return '${elapsed.inDays} days ago';
    }

    return '${created.day.toString().padLeft(2, '0')}/'
        '${created.month.toString().padLeft(2, '0')}/${created.year}';
  }
}
