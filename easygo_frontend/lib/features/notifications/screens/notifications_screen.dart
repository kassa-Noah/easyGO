import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

/// The signed-in account's notifications.
///
/// A notification is addressed to a user rather than to a role, so customers,
/// agency staff and administrators all read the same endpoint and share this
/// screen. There is no role-wide feed to show.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService.instance;

  String _selectedFilter = 'All';

  /// The filters follow the categories the API stores, grouped into the three
  /// headings a reader scans for.
  final List<String> _filters = <String>[
    'All',
    'Unread',
    ...notificationGroups,
  ];

  List<Map<String, dynamic>> _notifications = <Map<String, dynamic>>[];

  bool _isLoading = true;
  bool _isMarkingAll = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<AppNotification> items = await _service.getMine();

      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = items.map(_toCard).toList();
        _isLoading = false;
        _isMarkingAll = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
        _isMarkingAll = false;
      });
    }
  }

  /// Projects a notification onto the keys the card renders.
  Map<String, dynamic> _toCard(AppNotification notification) {
    return <String, dynamic>{
      'id': notification.id,
      'title': notification.title,
      'message': notification.message,
      'type': notification.groupLabel,
      'time': notification.ageLabel(),
      'isRead': notification.isRead,
      'icon': notification.icon,
    };
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    }

    if (_selectedFilter == 'Unread') {
      return _notifications
          .where((notification) => notification['isRead'] == false)
          .toList();
    }

    return _notifications
        .where((notification) => notification['type'] == _selectedFilter)
        .toList();
  }

  int get _unreadCount {
    return _notifications
        .where((notification) => notification['isRead'] == false)
        .length;
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    if (notification['isRead'] == true) {
      return;
    }

    final String id = notification['id'] as String;

    try {
      await _service.markAsRead(id);
    } on ApiException {
      // The list is re-read below either way, so a failure here simply leaves
      // the notification unread rather than reporting success.
    }

    if (mounted) {
      await _load();
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isMarkingAll = true;
    });

    try {
      final int updated = await _service.markAllAsRead();

      if (!mounted) {
        return;
      }

      await _load();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated == 0
                ? 'Nothing was left unread.'
                : 'Marked $updated '
                      '${updated == 1 ? 'notification' : 'notifications'} '
                      'as read.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isMarkingAll = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Tracking':
        return AppColors.secondary;

      case 'System':
        return AppColors.warning;

      case 'Journey':
      default:
        return AppColors.primary;
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unable to load your notifications.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final notifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _isMarkingAll ? null : _markAllAsRead,
              child: Text(l10n.markAllAsRead),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummary(),

            _buildFilters(),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _buildErrorState()
                  : notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];

                        return _buildNotificationCard(notification);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Updated',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _unreadCount == 0
                      ? 'You have no unread notifications.'
                      : 'You have $_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}.',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 58,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        scrollDirection: Axis.horizontal,
        children: _filters.map((filter) {
          final bool selected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'] == true;

    final String type = notification['type'];

    final Color typeColor = _typeColor(type);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _markAsRead(notification);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead
                  ? AppColors.border
                  : typeColor.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      notification['icon'],
                      color: typeColor,
                      size: 22,
                    ),
                  ),

                  if (!isRead)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: typeColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          notification['time'],
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification['message'],
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none_outlined,
              size: 70,
              color: AppColors.textLight,
            ),

            const SizedBox(height: 16),

            Text(
              _selectedFilter == 'Unread'
                  ? 'No Unread Notifications'
                  : 'No Notifications',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Notifications addressed to your account will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
