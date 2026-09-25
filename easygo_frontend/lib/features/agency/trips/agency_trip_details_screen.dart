import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/agency_console.dart';
import '../services/agency_console_service.dart';
import 'edit_trip_screen.dart';
import 'manage_trip_availability_screen.dart';

class AgencyTripDetailsScreen extends StatefulWidget {
  const AgencyTripDetailsScreen({super.key, required this.trip});

  final Map<String, dynamic> trip;

  @override
  State<AgencyTripDetailsScreen> createState() =>
      _AgencyTripDetailsScreenState();
}

class _AgencyTripDetailsScreenState extends State<AgencyTripDetailsScreen> {
  final AgencyConsoleService _console = AgencyConsoleService.instance;

  /// Held in state rather than read straight off the widget so the screen can
  /// show the result of an edit or a capacity change as soon as the user
  /// returns from it.
  late Map<String, dynamic> _trip = widget.trip;

  Map<String, dynamic> get trip => _trip;

  /// Re-reads the trip from the agency's own trip list. There is no
  /// single-trip staff endpoint, so the scoped list is the source of truth.
  Future<void> _refresh() async {
    final String id = _trip['id'] as String? ?? '';

    if (id.isEmpty) {
      return;
    }

    try {
      final List<ConsoleTrip> trips = await _console.getTrips();

      ConsoleTrip? updated;

      for (final ConsoleTrip item in trips) {
        if (item.id == id) {
          updated = item;
          break;
        }
      }

      if (!mounted || updated == null) {
        return;
      }

      final Map<String, dynamic> card = consoleTripToCard(updated);

      setState(() => _trip = card);
    } on ApiException {
      // Keep showing the last known values rather than blanking the screen.
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return AppColors.primary;
      case 'In Progress':
        return AppColors.warning;
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
      case 'Scheduled':
        return Icons.schedule_outlined;
      case 'In Progress':
        return Icons.directions_bus_outlined;
      case 'Completed':
        return Icons.check_circle_outline;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  Future<void> _openEditTrip(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTripScreen(trip: trip)),
    );

    if (mounted) {
      await _refresh();
    }
  }

  Future<void> _openAvailability(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageTripAvailabilityScreen(trip: trip),
      ),
    );

    if (mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final String status = trip['status'] as String;

    final int bookedSeats = trip['bookedSeats'] as int;

    final int totalSeats = trip['totalSeats'] as int;

    final int availableSeats = totalSeats - bookedSeats;

    final double occupancy = totalSeats == 0 ? 0 : bookedSeats / totalSeats;

    final bool canManage = status == 'Scheduled';

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTripHeader(context, status),
                    const SizedBox(height: 18),
                    _buildRouteCard(context),
                    const SizedBox(height: 18),
                    _buildTripInformation(context),
                    const SizedBox(height: 18),
                    _buildCapacitySection(
                      context,
                      bookedSeats: bookedSeats,
                      totalSeats: totalSeats,
                      availableSeats: availableSeats,
                      occupancy: occupancy,
                    ),
                    const SizedBox(height: 18),
                    _buildManagementSection(context, canManage: canManage),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripHeader(BuildContext context, String status) {
    final Color color = _statusColor(status);

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.directions_bus_outlined,
              color: AppColors.primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip['departureCity']} → '
                  '${trip['destinationCity']}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  trip['id'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon(status), size: 14, color: color),
                const SizedBox(width: 5),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Route & Schedule'),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRouteTimeline(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    _RoutePoint(
                      label: 'Departure',
                      city: trip['departureCity'] as String,
                      time: trip['departureTime'] as String,
                    ),
                    const SizedBox(height: 28),
                    _RoutePoint(
                      label: 'Arrival',
                      city: trip['destinationCity'] as String,
                      time: trip['arrivalTime'] as String,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 9),
              Text(
                trip['date'] as String,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTimeline() {
    return SizedBox(
      width: 22,
      height: 104,
      child: Column(
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              width: 2,
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          Container(
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInformation(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Trip Information'),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 550;

              final double itemWidth = wide
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _InformationTile(
                      label: 'Travel Class',
                      value: trip['travelClass'] as String,
                      icon: Icons.event_seat_outlined,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _InformationTile(
                      label: 'Passenger Fare',
                      value: '${_formatPrice(trip['price'] as int)} FCFA',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _InformationTile(
                      label: 'Departure Time',
                      value: trip['departureTime'] as String,
                      icon: Icons.departure_board_outlined,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _InformationTile(
                      label: 'Arrival Time',
                      value: trip['arrivalTime'] as String,
                      icon: Icons.schedule_outlined,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySection(
    BuildContext context, {
    required int bookedSeats,
    required int totalSeats,
    required int availableSeats,
    required double occupancy,
  }) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Seat Availability'),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CapacityValue(
                  value: '$totalSeats',
                  label: 'Total Seats',
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _CapacityValue(value: '$bookedSeats', label: 'Booked'),
              ),
              Container(
                width: 1,
                height: 50,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _CapacityValue(
                  value: '$availableSeats',
                  label: 'Available',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Seat occupancy',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '${(occupancy * 100).round()}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: occupancy,
              minHeight: 7,
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(
    BuildContext context, {
    required bool canManage,
  }) {
    final String status = trip['status'] as String;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Trip Management'),
          const SizedBox(height: 8),
          Text(
            canManage
                ? 'Update this scheduled trip or manage its seat availability.'
                : 'Management actions are unavailable because this trip is $status.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canManage
                  ? () {
                      _openEditTrip(context);
                    }
                  : null,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Trip'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: canManage
                  ? () {
                      _openAvailability(context);
                    }
                  : null,
              icon: const Icon(Icons.event_seat_outlined),
              label: const Text('Manage Availability'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.label,
    required this.city,
    required this.time,
  });

  final String label;
  final String city;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 3),
              Text(
                city,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _InformationTile extends StatelessWidget {
  const _InformationTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityValue extends StatelessWidget {
  const _CapacityValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
