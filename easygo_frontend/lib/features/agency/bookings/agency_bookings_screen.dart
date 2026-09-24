import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'agency_booking_details_screen.dart';

class AgencyBookingsScreen extends StatefulWidget {
  const AgencyBookingsScreen({
    super.key,
  });

  @override
  State<AgencyBookingsScreen> createState() =>
      _AgencyBookingsScreenState();
}

class _AgencyBookingsScreenState
    extends State<AgencyBookingsScreen> {
  static const String _all = 'All';
  static const String _confirmed = 'Confirmed';
  static const String _completed = 'Completed';
  static const String _cancelled = 'Cancelled';

  String _selectedFilter = _all;

  static const List<String> _filters = [
    _all,
    _confirmed,
    _completed,
    _cancelled,
  ];

  static const List<Map<String, dynamic>> _bookings = [
    {
      'bookingReference': 'DEMO-BOOKING-001',
      'ticketReference': 'DEMO-TICKET-001',
      'clientName': 'John Doe',
      'clientPhone': '+237 6 70 00 00 01',
      'tripId': 'TRIP-DEMO-001',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Douala',
      'date': '20 Sep 2026',
      'departureTime': '07:00',
      'arrivalTime': '11:00',
      'travelClass': 'VIP',
      'bookingMode': 'Door-to-Door',
      'passengers': 1,
      'luggage': 1,
      'amount': 12500,
      'paymentMethod': 'MTN Mobile Money',
      'paymentStatus': 'Paid',
      'status': 'Confirmed',
      'pickupLocation': 'Bastos, Yaoundé',
      'finalDestination': 'Bonapriso, Douala',
    },
    {
      'bookingReference': 'DEMO-BOOKING-002',
      'ticketReference': 'DEMO-TICKET-002',
      'clientName': 'Marie N.',
      'clientPhone': '+237 6 70 00 00 02',
      'tripId': 'TRIP-DEMO-002',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Bafoussam',
      'date': '25 Sep 2026',
      'departureTime': '09:30',
      'arrivalTime': '13:30',
      'travelClass': 'Classic',
      'bookingMode': 'Interurban Only',
      'passengers': 1,
      'luggage': 2,
      'amount': 5000,
      'paymentMethod': 'Orange Money',
      'paymentStatus': 'Paid',
      'status': 'Confirmed',
      'pickupLocation': null,
      'finalDestination': null,
    },
    {
      'bookingReference': 'DEMO-BOOKING-003',
      'ticketReference': 'DEMO-TICKET-003',
      'clientName': 'Samuel T.',
      'clientPhone': '+237 6 70 00 00 03',
      'tripId': 'TRIP-DEMO-003',
      'departureCity': 'Douala',
      'destinationCity': 'Yaoundé',
      'date': '04 Aug 2026',
      'departureTime': '08:00',
      'arrivalTime': '12:00',
      'travelClass': 'VIP',
      'bookingMode': 'Interurban Only',
      'passengers': 1,
      'luggage': 1,
      'amount': 7000,
      'paymentMethod': 'MTN Mobile Money',
      'paymentStatus': 'Paid',
      'status': 'Completed',
      'pickupLocation': null,
      'finalDestination': null,
    },
    {
      'bookingReference': 'DEMO-BOOKING-004',
      'ticketReference': 'DEMO-TICKET-004',
      'clientName': 'Grace M.',
      'clientPhone': '+237 6 70 00 00 04',
      'tripId': 'TRIP-DEMO-004',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Buea',
      'date': '18 Jul 2026',
      'departureTime': '06:30',
      'arrivalTime': '12:30',
      'travelClass': 'Classic',
      'bookingMode': 'Interurban Only',
      'passengers': 1,
      'luggage': 0,
      'amount': 7000,
      'paymentMethod': 'Orange Money',
      'paymentStatus': 'Paid',
      'status': 'Cancelled',
      'pickupLocation': null,
      'finalDestination': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == _all) {
      return _bookings;
    }

    return _bookings
        .where(
          (booking) =>
              booking['status'] == _selectedFilter,
        )
        .toList();
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  void _openBookingDetails(
    Map<String, dynamic> booking,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgencyBookingDetailsScreen(
          booking: booking,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final List<Map<String, dynamic>> bookings =
        _filteredBookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agency Bookings',
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              32,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildSummary(context),
                      const SizedBox(height: 22),
                      _buildFilters(),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 250,
                        ),
                        child: bookings.isEmpty
                            ? _buildEmptyState(context)
                            : Column(
                                key: ValueKey(
                                  _selectedFilter,
                                ),
                                children: bookings
                                    .map(
                                      (booking) => Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          bottom: 14,
                                        ),
                                        child:
                                            _AgencyBookingCard(
                                          booking: booking,
                                          formattedAmount:
                                              _formatPrice(
                                            booking['amount']
                                                as int,
                                          ),
                                          onTap: () {
                                            _openBookingDetails(
                                              booking,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
  ) {
    final int confirmed = _bookings
        .where(
          (booking) =>
              booking['status'] == _confirmed,
        )
        .length;

    final int completed = _bookings
        .where(
          (booking) =>
              booking['status'] == _completed,
        )
        .length;

    final int cancelled = _bookings
        .where(
          (booking) =>
              booking['status'] == _cancelled,
        )
        .length;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Management',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'General Express • '
                      '${_bookings.length} bookings',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryBadge(
                label: 'Confirmed',
                value: confirmed,
                color: AppColors.primary,
              ),
              _SummaryBadge(
                label: 'Completed',
                value: completed,
                color: AppColors.success,
              ),
              _SummaryBadge(
                label: 'Cancelled',
                value: cancelled,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map(
          (filter) {
            final bool selected =
                filter == _selectedFilter;

            return Padding(
              padding: const EdgeInsets.only(
                right: 9,
              ),
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
          },
        ).toList(),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final String title =
        _selectedFilter == _all
            ? 'No bookings'
            : 'No $_selectedFilter bookings';

    return GlassContainer(
      key: ValueKey(
        'empty-bookings-$_selectedFilter',
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      borderRadius: 18,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            'There are currently no agency bookings under this status.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AgencyBookingCard extends StatelessWidget {
  const _AgencyBookingCard({
    required this.booking,
    required this.formattedAmount,
    required this.onTap,
  });

  final Map<String, dynamic> booking;
  final String formattedAmount;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (booking['status']) {
      case 'Confirmed':
        return AppColors.primary;
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _statusIcon {
    switch (booking['status']) {
      case 'Confirmed':
        return Icons.check_circle_outline;
      case 'Completed':
        return Icons.task_alt;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      onTap: onTap,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['bookingReference']
                          as String,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['clientName'] as String,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon,
                      size: 13,
                      color: _statusColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      booking['status'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${booking['departureCity']} → '
                  '${booking['destinationCity']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _BookingInformation(
                icon: Icons.calendar_today_outlined,
                value: booking['date'] as String,
              ),
              _BookingInformation(
                icon: Icons.directions_outlined,
                value: booking['bookingMode'] as String,
              ),
              _BookingInformation(
                icon: Icons.people_outline,
                value:
                    '${booking['passengers']} passenger'
                    '${booking['passengers'] == 1 ? '' : 's'}',
              ),
              _BookingInformation(
                icon: Icons.luggage_outlined,
                value:
                    '${booking['luggage']} luggage',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 17,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '$formattedAmount FCFA',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                booking['paymentStatus'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingInformation extends StatelessWidget {
  const _BookingInformation({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.primary,
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

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}