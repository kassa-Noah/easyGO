import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'trip_details_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({
    super.key,
  });

  @override
  State<MyTripsScreen> createState() =>
      _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  static const String _upcoming = 'Upcoming';
  static const String _completed = 'Completed';
  static const String _cancelled = 'Cancelled';

  String _selectedFilter = _upcoming;

  static const List<String> _filters = [
    _upcoming,
    _completed,
    _cancelled,
  ];

  /*
   * DEMONSTRATION DATA ONLY.
   *
   * Production records will be retrieved from
   * the backend for the authenticated client.
   *
   * Status and bookingMode remain canonical
   * internal values. Localization is applied
   * only when values are displayed.
   */
  final List<Map<String, dynamic>> _trips = [
    {
      'bookingReference': 'DEMO-BOOKING-001',
      'ticketReference': 'DEMO-TICKET-001',
      'agency': 'General Express',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Douala',
      'date': '20 Sep 2026',
      'departureTime': '07:00',
      'arrivalTime': '11:00',
      'travelClass': 'VIP',
      'bookingMode': 'Door-to-Door',
      'status': 'Upcoming',
      'passengers': 1,
      'luggage': 1,
      'amount': 12500,
      'paymentMethod': 'MTN Mobile Money',
      'pickupLocation':
          'Traveler pickup address, Yaoundé',
      'finalDestination':
          'Traveler destination address, Douala',
      'luggageItems': [
        {
          'trackingReference': 'LUG-DEMO-001',
          'description': 'Traveler suitcase',
          'weight': '18 kg',
          'status': 'In Transit',
        },
      ],
    },
    {
      'bookingReference': 'DEMO-BOOKING-002',
      'ticketReference': 'DEMO-TICKET-002',
      'agency': 'Finexs Voyage',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Bafoussam',
      'date': '25 Sep 2026',
      'departureTime': '09:30',
      'arrivalTime': '13:30',
      'travelClass': 'Classic',
      'bookingMode': 'Interurban Only',
      'status': 'Upcoming',
      'passengers': 1,
      'luggage': 2,
      'amount': 5000,
      'paymentMethod': 'Orange Money',
      'pickupLocation': null,
      'finalDestination': null,
      'luggageItems': [
        {
          'trackingReference': 'LUG-DEMO-002',
          'description': 'Medium blue travel bag',
          'weight': '12 kg',
          'status': 'Received by Agency',
        },
        {
          'trackingReference': 'LUG-DEMO-003',
          'description': 'Traveler suitcase',
          'weight': '15 kg',
          'status': 'Received by Agency',
        },
      ],
    },
    {
      'bookingReference': 'DEMO-BOOKING-003',
      'ticketReference': 'DEMO-TICKET-003',
      'agency': 'Touristique Express',
      'departureCity': 'Douala',
      'destinationCity': 'Yaoundé',
      'date': '04 Aug 2026',
      'departureTime': '08:00',
      'arrivalTime': '12:00',
      'travelClass': 'VIP',
      'bookingMode': 'Interurban Only',
      'status': 'Completed',
      'passengers': 1,
      'luggage': 1,
      'amount': 7000,
      'paymentMethod': 'MTN Mobile Money',
      'pickupLocation': null,
      'finalDestination': null,
      'luggageItems': [
        {
          'trackingReference': 'LUG-DEMO-004',
          'description': 'Traveler suitcase',
          'weight': '16 kg',
          'status': 'Delivered',
        },
      ],
    },
    {
      'bookingReference': 'DEMO-BOOKING-004',
      'ticketReference': 'DEMO-TICKET-004',
      'agency': 'General Express',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Buea',
      'date': '18 Jul 2026',
      'departureTime': '06:30',
      'arrivalTime': '12:30',
      'travelClass': 'Classic',
      'bookingMode': 'Interurban Only',
      'status': 'Cancelled',
      'passengers': 1,
      'luggage': 0,
      'amount': 7000,
      'paymentMethod': 'Orange Money',
      'pickupLocation': null,
      'finalDestination': null,
      'luggageItems': <Map<String, dynamic>>[],
    },
  ];

  List<Map<String, dynamic>> get _filteredTrips {
    return _trips
        .where(
          (trip) => trip['status'] == _selectedFilter,
        )
        .toList();
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case _upcoming:
        return AppColors.primary;
      case _completed:
        return AppColors.success;
      case _cancelled:
        return AppColors.error;
      default:
        return Theme.of(context)
            .colorScheme
            .onSurfaceVariant;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case _upcoming:
        return Icons.schedule_outlined;
      case _completed:
        return Icons.check_circle_outline;
      case _cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.confirmation_num_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> trips =
        _filteredTrips;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l10n.myTrips,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF09111F),
                    Color(0xFF0D1B2A),
                    Color(0xFF10253B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF2F8FF),
                    Color(0xFFF7FBFF),
                    Color(0xFFF1FFF6),
                  ],
                ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildFilters(
                context,
                l10n,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: trips.isEmpty
                      ? _buildEmptyState(
                          context,
                          l10n,
                          key: ValueKey(
                            'empty-$_selectedFilter',
                          ),
                        )
                      : _buildTripList(
                          trips,
                          l10n,
                          key: ValueKey(
                            _selectedFilter,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            8,
          ),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            borderRadius: 18,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map(
                  (filter) {
                    final bool selected =
                        filter == _selectedFilter;

                    final Color color =
                        _statusColor(filter);

                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 220,
                        ),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(
                                  alpha: 0.14,
                                )
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: ChoiceChip(
                          avatar: Icon(
                            _statusIcon(filter),
                            size: 17,
                            color: selected
                                ? color
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                          label: Text(
                            l10n.tripStatusLabel(
                              filter,
                            ),
                          ),
                          selected: selected,
                          showCheckmark: false,
                          side: BorderSide.none,
                          backgroundColor:
                              Colors.transparent,
                          selectedColor:
                              Colors.transparent,
                          labelStyle: TextStyle(
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: selected
                                ? color
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                          onSelected: (_) {
                            if (_selectedFilter ==
                                filter) {
                              return;
                            }

                            setState(() {
                              _selectedFilter =
                                  filter;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripList(
    List<Map<String, dynamic>> trips,
    AppLocalizations l10n, {
    required Key key,
  }) {
    return ListView.builder(
      key: key,
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        28,
      ),
      itemCount: trips.length,
      itemBuilder: (
        context,
        index,
      ) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: _buildTripCard(
                context,
                trips[index],
                l10n,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    Map<String, dynamic> trip,
    AppLocalizations l10n,
  ) {
    final String status =
        trip['status']?.toString() ?? '';

    final String bookingMode =
        trip['bookingMode']?.toString() ?? '';

    final bool isDoorToDoor =
        bookingMode == 'Door-to-Door';

    final int passengers =
        (trip['passengers'] as int?) ?? 0;

    final int luggage =
        (trip['luggage'] as int?) ?? 0;

    final int amount =
        (trip['amount'] as int?) ?? 0;

    return GlassContainer(
      width: double.infinity,
      padding: EdgeInsets.zero,
      borderRadius: 20,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TripDetailsScreen(
              trip: trip,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.directions_bus_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['agency']
                                ?.toString() ??
                            '',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        trip['bookingReference']
                                ?.toString() ??
                            '',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color:
                                  AppColors.primary,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _StatusBadge(
                  status: status,
                  label:
                      l10n.tripStatusLabel(
                    status,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _TripLocation(
                    time: trip['departureTime']
                            ?.toString() ??
                        '',
                    city: trip['departureCity']
                            ?.toString() ??
                        '',
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_bus_outlined,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 2,
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(
                            alpha: 0.55,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _TripLocation(
                    time: trip['arrivalTime']
                            ?.toString() ??
                        '',
                    city: trip['destinationCity']
                            ?.toString() ??
                        '',
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(
              color: Theme.of(context)
                  .dividerColor,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              crossAxisAlignment:
                  WrapCrossAlignment.center,
              children: [
                _MetadataItem(
                  icon: Icons
                      .calendar_today_outlined,
                  value:
                      trip['date']?.toString() ??
                          '',
                ),
                _MetadataItem(
                  icon:
                      Icons.event_seat_outlined,
                  value: trip['travelClass']
                          ?.toString() ??
                      '',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InformationChip(
                  icon: isDoorToDoor
                      ? Icons.home_outlined
                      : Icons
                          .directions_bus_outlined,
                  label:
                      l10n.bookingModeLabel(
                    bookingMode,
                  ),
                ),
                _InformationChip(
                  icon: Icons.person_outline,
                  label:
                      l10n.passengerCount(
                    passengers,
                  ),
                ),
                _InformationChip(
                  icon: Icons.luggage_outlined,
                  label:
                      l10n.luggageItemCount(
                    luggage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  l10n.amountLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
                const Spacer(),
                Text(
                  '${_formatPrice(amount)} FCFA',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppColors.primary,
                      ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n, {
    required Key key,
  }) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _statusColor(
                      _selectedFilter,
                    ).withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(
                      _selectedFilter,
                    ),
                    size: 34,
                    color: _statusColor(
                      _selectedFilter,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.emptyTripsTitle(
                    _selectedFilter,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.emptyTripsDescription(
                    _selectedFilter,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripLocation extends StatelessWidget {
  final String time;
  final String city;
  final bool alignEnd;

  const _TripLocation({
    required this.time,
    required this.city,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          textAlign: alignEnd
              ? TextAlign.end
              : TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          city,
          textAlign: alignEnd
              ? TextAlign.end
              : TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }
}

class _MetadataItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetadataItem({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const _StatusBadge({
    required this.status,
    required this.label,
  });

  Color get _color {
    switch (status) {
      case 'Upcoming':
        return AppColors.primary;
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'Upcoming':
        return Icons.schedule_outlined;
      case 'Completed':
        return Icons.check_circle_outline;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 13,
            color: _color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InformationChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withValues(
              alpha: 0.45,
            ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall,
          ),
        ],
      ),
    );
  }
}