import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../notifications/models/app_notification.dart';
import '../../notifications/services/notification_service.dart';

/// The administrator's own notifications.
///
/// Notifications are addressed to a user rather than to a role, so this reads
/// the same endpoint the customer app does; there is no administrator-wide feed.
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final NotificationService _notifications = NotificationService.instance;

  List<AppNotification> _items = <AppNotification>[];
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
      final List<AppNotification> items = await _notifications.getMine();

      if (!mounted) {
        return;
      }

      setState(() {
        _items = items;
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

  Future<void> _markAllAsRead() async {
    setState(() {
      _isMarkingAll = true;
    });

    try {
      final int updated = await _notifications.markAllAsRead();

      if (!mounted) {
        return;
      }

      // Re-read rather than assuming the new state: the backend decides which
      // rows changed.
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

  int get _unreadCount =>
      _items.where((AppNotification item) => !item.isRead).length;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminNotifications),
        actions: [
          TextButton(
            onPressed: _isMarkingAll || _isLoading || _unreadCount == 0
                ? null
                : _markAllAsRead,
            child: Text(l.markAllAsRead),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              borderRadius: 18,
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    color: AppColors.error,
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            )
          else if (_items.isEmpty)
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              borderRadius: 18,
              child: Text(
                'You have no notifications.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            for (final AppNotification item in _items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(item.icon),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: item.isRead
                            ? FontWeight.w500
                            : FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      '${item.message}\n'
                      '${item.groupLabel}'
                      '${item.ageLabel().isEmpty ? '' : ' • ${item.ageLabel()}'}',
                    ),
                    isThreeLine: true,
                    trailing: item.isRead ? null : const Badge(),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
