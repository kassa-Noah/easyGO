import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'manage_booking_status_screen.dart';

class AgencyBookingDetailsScreen extends StatelessWidget {
  const AgencyBookingDetailsScreen({
    super.key,
    required this.booking,
  });

  final Map<String, dynamic> booking;

  bool get _isDoorToDoor =>
      booking['bookingMode'] == 'Door-to-Door';

  bool get _canManage =>
      booking['status'] == 'Confirmed';

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  Color _statusColor(String status) {
    switch (status) {
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

  IconData _statusIcon(String status) {
    switch (status) {
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

  void _openStatusManagement(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ManageBookingStatusScreen(
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Details',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              34,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 850,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildBookingHeader(context),
                    const SizedBox(height: 18),
                    _buildClientSection(context),
                    const SizedBox(height: 18),
                    _buildTripSection(context),
                    const SizedBox(height: 18),
                    _buildBookingSection(context),
                    if (_isDoorToDoor) ...[
                      const SizedBox(height: 18),
                      _buildDoorToDoorSection(context),
                    ],
                    const SizedBox(height: 18),
                    _buildPaymentSection(context),
                    const SizedBox(height: 18),
                    _buildManagementSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingHeader(
    BuildContext context,
  ) {
    final String status =
        booking['status'] as String;

    final Color color =
        _statusColor(status);

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
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
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
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
                      booking['ticketReference']
                          as String,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon(status),
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.business_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Text(
                'General Express',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection(
    BuildContext context,
  ) {
    return _SectionCard(
      title: 'Client Information',
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Client Name',
            value:
                booking['clientName'] as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value:
                booking['clientPhone'] as String,
          ),
        ],
      ),
    );
  }

  Widget _buildTripSection(
    BuildContext context,
  ) {
    return _SectionCard(
      title: 'Trip Information',
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.route_outlined,
            label: 'Route',
            value:
                '${booking['departureCity']} → '
                '${booking['destinationCity']}',
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.directions_bus_outlined,
            label: 'Trip Reference',
            value:
                booking['tripId'] as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Travel Date',
            value: booking['date'] as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.schedule_outlined,
            label: 'Schedule',
            value:
                '${booking['departureTime']} – '
                '${booking['arrivalTime']}',
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.event_seat_outlined,
            label: 'Travel Class',
            value:
                booking['travelClass'] as String,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection(
    BuildContext context,
  ) {
    final int passengers =
        booking['passengers'] as int;

    final int luggage =
        booking['luggage'] as int;

    return _SectionCard(
      title: 'Booking Information',
      child: Column(
        children: [
          _DetailRow(
            icon: _isDoorToDoor
                ? Icons.home_work_outlined
                : Icons.directions_bus_outlined,
            label: 'Booking Mode',
            value:
                booking['bookingMode'] as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.people_outline,
            label: 'Passengers',
            value:
                '$passengers passenger'
                '${passengers == 1 ? '' : 's'}',
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.luggage_outlined,
            label: 'Registered Luggage',
            value:
                '$luggage item'
                '${luggage == 1 ? '' : 's'}',
          ),
        ],
      ),
    );
  }

  Widget _buildDoorToDoorSection(
    BuildContext context,
  ) {
    final String pickup =
        booking['pickupLocation']
                as String? ??
            'Not available';

    final String destination =
        booking['finalDestination']
                as String? ??
            'Not available';

    return _SectionCard(
      title: 'Door-to-Door Journey',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _JourneyStage(
            icon: Icons.home_outlined,
            title: 'Pickup Location',
            value: pickup,
          ),
          _buildJourneyConnector(),
          const _JourneyStage(
            icon: Icons.local_taxi_outlined,
            title: 'Pickup Taxi',
            value:
                'External provider assignment',
          ),
          _buildJourneyConnector(),
          const _JourneyStage(
            icon: Icons.business_outlined,
            title: 'Departure Agency',
            value: 'General Express',
          ),
          _buildJourneyConnector(),
          _JourneyStage(
            icon: Icons.directions_bus_outlined,
            title: 'Interurban Trip',
            value:
                '${booking['departureCity']} → '
                '${booking['destinationCity']}',
          ),
          _buildJourneyConnector(),
          const _JourneyStage(
            icon: Icons.business_outlined,
            title: 'Arrival Agency',
            value: 'General Express',
          ),
          _buildJourneyConnector(),
          const _JourneyStage(
            icon: Icons.local_taxi_outlined,
            title: 'Destination Taxi',
            value:
                'External provider assignment',
          ),
          _buildJourneyConnector(),
          _JourneyStage(
            icon: Icons.location_on_outlined,
            title: 'Final Destination',
            value: destination,
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyConnector() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 19,
      ),
      child: Container(
        width: 2,
        height: 20,
        color: AppColors.primary.withValues(
          alpha: 0.25,
        ),
      ),
    );
  }

  Widget _buildPaymentSection(
    BuildContext context,
  ) {
    final String paymentStatus =
        booking['paymentStatus'] as String;

    final Color paymentColor =
        paymentStatus == 'Paid'
            ? AppColors.success
            : AppColors.warning;

    return _SectionCard(
      title: 'Payment Information',
      child: Column(
        children: [
          _DetailRow(
            icon:
                Icons.account_balance_wallet_outlined,
            label: 'Payment Method',
            value:
                booking['paymentMethod'] as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.payments_outlined,
            label: 'Amount Paid',
            value:
                '${_formatPrice(booking['amount'] as int)} FCFA',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: paymentColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.verified_outlined,
                  size: 19,
                  color: paymentColor,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Status',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      paymentStatus,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.w600,
                            color: paymentColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(
    BuildContext context,
  ) {
    final String status =
        booking['status'] as String;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
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
          const SizedBox(height: 7),
          Text(
            _canManage
                ? 'This confirmed booking can be completed or cancelled according to the booking lifecycle.'
                : 'Status management is unavailable because this booking is $status.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _canManage
                  ? () {
                      _openStatusManagement(
                        context,
                      );
                    }
                  : null,
              icon: const Icon(
                Icons.manage_history_outlined,
              ),
              label: const Text(
                'Manage Booking Status',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall,
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JourneyStage extends StatelessWidget {
  const _JourneyStage({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.10,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 19,
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
                title,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall,
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}