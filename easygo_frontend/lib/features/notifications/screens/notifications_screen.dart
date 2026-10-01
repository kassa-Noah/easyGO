import 'package:flutter/material.dart';

import '../../../../shared/widgets/skeleton.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../admin/agencies/admin_agencies_screen.dart';
import '../../admin/operations/admin_bookings_screen.dart';
import '../../admin/operations/admin_luggage_screen.dart';
import '../../admin/operations/admin_parcels_screen.dart';
import '../../admin/operations/admin_trips_screen.dart';
import '../../agency/bookings/agency_bookings_screen.dart';
import '../../agency/luggage/agency_luggage_screen.dart';
import '../../agency/messages/agency_chat_screen.dart';
import '../../agency/parcels/agency_parcels_screen.dart';
import '../../agency/trips/agency_trips_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../client/agencies/agency_conversation_screen.dart';
import '../../client/tracking/my_parcels_screen.dart';
import '../../client/tracking/traveler_luggage_screen.dart';
import '../../client/trips/my_trips_screen.dart';
import '../../messages/models/conversation.dart';
import '../../messages/services/messaging_service.dart';
import '../models/app_notification.dart';
import '../notification_route.dart';
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

  final MessagingService _messaging = MessagingService.instance;

  final AuthService _auth = AuthService.instance;

  String _selectedFilter = 'All';

  /// The role the account signs in with, which decides which console a
  /// notification opens. Read once, when the list is first loaded.
  String? _role;

  /// The notification currently being opened, so its card can show that
  /// something is happening rather than looking unchanged.
  String? _openingId;

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

      // The console a notification opens depends on the role, and the role is
      // not carried around the app. A failure here is not fatal: every
      // notification still reads, and only the role-dependent links are lost.
      await _loadRoleOnce();

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

  Future<void> _loadRoleOnce() async {
    if (_role != null) {
      return;
    }

    try {
      _role = (await _auth.getCurrentUser()).role;
    } on ApiException {
      // Left unknown. `notificationDestination` resolves what it can without it
      // and offers no link for the rest.
      _role = null;
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
      'referenceType': notification.referenceType,
      'referenceId': notification.referenceId,
      'destination': notificationDestination(
        referenceType: notification.referenceType,
        role: _role,
      ),
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

  /// Records that the reader has seen this notification.
  ///
  /// The card is updated in place rather than by reloading the list. Reloading
  /// set `_isLoading`, so the whole list was replaced by a spinner and came back
  /// a moment later — tapping a notification made the screen flash.
  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    if (notification['isRead'] == true) {
      return;
    }

    final String id = notification['id'] as String;

    try {
      await _service.markAsRead(id);
    } on ApiException {
      // Left unread rather than reported as read.
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      notification['isRead'] = true;
    });
  }

  /// Opens a notification: reads it, and goes where it points if it points
  /// anywhere.
  Future<void> _open(Map<String, dynamic> notification) async {
    final NotificationDestination destination =
        notification['destination'] as NotificationDestination? ??
        NotificationDestination.none;

    if (destination == NotificationDestination.none) {
      // Nothing points anywhere, which the card already said by carrying no
      // chevron. Marking it read is the whole of what tapping it does.
      await _markAsRead(notification);
      return;
    }

    setState(() {
      _openingId = notification['id'] as String?;
    });

    try {
      await _markAsRead(notification);

      if (!mounted) {
        return;
      }

      if (destination == NotificationDestination.conversation) {
        await _openConversation(notification['referenceId'] as String);
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => _screenFor(destination)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingId = null;
        });
      }
    }
  }

  /// Opens the thread a message notification came from.
  ///
  /// The thread is fetched by id rather than taken from the message, because the
  /// notification records which conversation it is about and not what was said
  /// in it.
  Future<void> _openConversation(String conversationId) async {
    try {
      final Conversation conversation = await _messaging.getConversation(
        conversationId,
      );

      if (!mounted) {
        return;
      }

      // The customer reads a thread as a conversation with an agency and the
      // agency reads the same thread as a conversation with a client. The two
      // screens differ in whose name is at the top, which is the whole point of
      // having two, so the role decides which one opens.
      final Widget screen = _role == roleCustomer
          ? AgencyConversationScreen(
              agency: <String, dynamic>{
                'id': conversation.agencyId,
                'name': conversation.agencyName,
              },
            )
          : AgencyChatScreen(conversation: conversationToCard(conversation));

      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => screen),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  /// The screen a destination names.
  ///
  /// Every one of these is a list that contains the record, not the record's own
  /// page; `notification_route.dart` says why.
  Widget _screenFor(NotificationDestination destination) {
    switch (destination) {
      case NotificationDestination.clientTrips:
        return const MyTripsScreen();

      case NotificationDestination.agencyBookings:
        return const AgencyBookingsScreen();

      case NotificationDestination.adminBookings:
        return const AdminBookingsScreen();

      case NotificationDestination.agencyTrips:
        return const AgencyTripsScreen();

      case NotificationDestination.adminTrips:
        return const AdminTripsScreen();

      case NotificationDestination.clientParcels:
        return const MyParcelsScreen();

      case NotificationDestination.agencyParcels:
        return const AgencyParcelsScreen();

      case NotificationDestination.adminParcels:
        return const AdminParcelsScreen();

      case NotificationDestination.clientLuggage:
        return const TravelerLuggageScreen();

      case NotificationDestination.agencyLuggage:
        return const AgencyLuggageScreen();

      case NotificationDestination.adminLuggage:
        return const AdminLuggageScreen();

      case NotificationDestination.adminAgencies:
        return const AdminAgenciesScreen();

      case NotificationDestination.conversation:
      case NotificationDestination.none:
        // Neither reaches here: a conversation is opened by id above, and `none`
        // is returned from before this is called.
        return const SizedBox.shrink();
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

      case 'Messages':
        return AppColors.primaryDark;

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
                  ? const SkeletonList(rows: 5, height: 88)
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

    final NotificationDestination destination =
        notification['destination'] as NotificationDestination? ??
        NotificationDestination.none;

    final bool isOpening = _openingId == notification['id'];

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _open(notification);
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

              // A card that leads somewhere says so; one that does not carries
              // no chevron. Tapping used to do nothing visible on either kind,
              // which gave the reader no way to tell them apart.
              if (isOpening) ...[
                const SizedBox(width: 10),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ] else if (destination != NotificationDestination.none) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                ),
              ],
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
