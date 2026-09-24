import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Unread',
    'Travel',
    'Tracking',
  ];

  final List<Map<String, dynamic>>
      _notifications = [
    {
      'id': 'notification_001',
      'title': 'Booking Confirmed',
      'message':
          'Your General Express journey from Yaoundé to Douala has been confirmed.',
      'type': 'Travel',
      'time': '10 min ago',
      'isRead': false,
      'icon': Icons.check_circle_outline,
    },
    {
      'id': 'notification_002',
      'title': 'Payment Successful',
      'message':
          'Your payment of 12,500 FCFA for booking DEMO-BOOKING-001 was successful.',
      'type': 'Travel',
      'time': '12 min ago',
      'isRead': false,
      'icon':
          Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'notification_003',
      'title': 'Luggage In Transit',
      'message':
          'Luggage LUG-DEMO-001 is now in transit from Yaoundé to Douala.',
      'type': 'Tracking',
      'time': '1 hour ago',
      'isRead': false,
      'icon': Icons.luggage_outlined,
    },
    {
      'id': 'notification_004',
      'title': 'Parcel Status Updated',
      'message':
          'Parcel PAR-DEMO-001 has been received by the transport agency.',
      'type': 'Tracking',
      'time': '3 hours ago',
      'isRead': true,
      'icon': Icons.inventory_2_outlined,
    },
    {
      'id': 'notification_005',
      'title': 'Upcoming Journey',
      'message':
          'Your Yaoundé to Douala journey is scheduled for 20 September 2026 at 07:00.',
      'type': 'Travel',
      'time': 'Yesterday',
      'isRead': true,
      'icon': Icons.directions_bus_outlined,
    },
    {
      'id': 'notification_006',
      'title': 'Door-to-Door Service',
      'message':
          'Taxi assignment information will appear here when the external taxi provider assigns your pickup driver.',
      'type': 'Travel',
      'time': 'Yesterday',
      'isRead': true,
      'icon': Icons.local_taxi_outlined,
    },
  ];

  List<Map<String, dynamic>>
      get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    }

    if (_selectedFilter == 'Unread') {
      return _notifications
          .where(
            (notification) =>
                notification['isRead'] ==
                false,
          )
          .toList();
    }

    return _notifications
        .where(
          (notification) =>
              notification['type'] ==
              _selectedFilter,
        )
        .toList();
  }

  int get _unreadCount {
    return _notifications
        .where(
          (notification) =>
              notification['isRead'] ==
              false,
        )
        .length;
  }

  void _markAsRead(
    Map<String, dynamic> notification,
  ) {
    if (notification['isRead'] == true) {
      return;
    }

    setState(() {
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification
          in _notifications) {
        notification['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'All notifications marked as read.',
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Tracking':
        return AppColors.secondary;

      case 'Travel':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications =
        _filteredNotifications;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummary(),

            _buildFilters(),

            Expanded(
              child: notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        20,
                        10,
                        20,
                        24,
                      ),
                      itemCount:
                          notifications
                              .length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(
                        height: 12,
                      ),
                      itemBuilder:
                          (context, index) {
                        final notification =
                            notifications[
                                index];

                        return _buildNotificationCard(
                          notification,
                        );
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
      margin:
          const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        10,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.15,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .notifications_outlined,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Updated',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _unreadCount == 0
                      ? 'You have no unread notifications.'
                      : 'You have $_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}.',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.white70,
                  ),
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
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 9,
        ),
        scrollDirection:
            Axis.horizontal,
        children: _filters.map(
          (filter) {
            final bool selected =
                _selectedFilter ==
                    filter;

            return Padding(
              padding:
                  const EdgeInsets.only(
                right: 9,
              ),
              child: ChoiceChip(
                label: Text(filter),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter =
                        filter;
                  });
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
  ) {
    final bool isRead =
        notification['isRead'] == true;

    final String type =
        notification['type'];

    final Color typeColor =
        _typeColor(type);

    return Material(
      color: AppColors.surface,
      borderRadius:
          BorderRadius.circular(16),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: () {
          _markAsRead(notification);
        },
        child: Container(
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: isRead
                  ? AppColors.border
                  : typeColor
                      .withValues(
                    alpha: 0.35,
                  ),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration:
                        BoxDecoration(
                      color: typeColor
                          .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        13,
                      ),
                    ),
                    child: Icon(
                      notification[
                          'icon'],
                      color: typeColor,
                      size: 22,
                    ),
                  ),

                  if (!isRead)
                    Positioned(
                      top: -2,
                      right: -2,
                      child:
                          Container(
                        width: 10,
                        height: 10,
                        decoration:
                            BoxDecoration(
                          color:
                              typeColor,
                          shape: BoxShape
                              .circle,
                          border:
                              Border.all(
                            color: Colors
                                .white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification[
                                'title'],
                            style:
                                TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isRead
                                      ? FontWeight
                                          .w600
                                      : FontWeight
                                          .bold,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Text(
                          notification[
                              'time'],
                          style:
                              const TextStyle(
                            fontSize: 9,
                            color: AppColors
                                .textLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      notification[
                          'message'],
                      style:
                          const TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color: typeColor
                            .withValues(
                          alpha: 0.08,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Text(
                        type,
                        style:
                            TextStyle(
                          fontSize: 9,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color:
                              typeColor,
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
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .notifications_none_outlined,
              size: 70,
              color:
                  AppColors.textLight,
            ),

            const SizedBox(height: 16),

            Text(
              _selectedFilter ==
                      'Unread'
                  ? 'No Unread Notifications'
                  : 'No Notifications',
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Notifications related to your journeys, luggage and parcels will appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}