import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/agency_console.dart';
import '../services/agency_console_service.dart';
import 'agency_trip_details_screen.dart';
import 'create_trip_screen.dart';

class AgencyTripsScreen extends StatefulWidget {
  const AgencyTripsScreen({super.key});

  @override
  State<AgencyTripsScreen> createState() => _AgencyTripsScreenState();
}

class _AgencyTripsScreenState extends State<AgencyTripsScreen> {
  static const String _all = 'All';
  static const String _scheduled = 'Scheduled';
  static const String _inProgress = 'In Progress';
  static const String _completed = 'Completed';
  static const String _cancelled = 'Cancelled';

  String _selectedFilter = _all;

  static const List<String> _filters = [
    _all,
    _scheduled,
    _inProgress,
    _completed,
    _cancelled,
  ];

  final AgencyConsoleService _console = AgencyConsoleService.instance;

  List<Map<String, dynamic>> _trips = <Map<String, dynamic>>[];
  bool _isLoading = true;
  String? _errorMessage;
  String? _agencyName;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<ConsoleTrip> trips = await _console.getTrips();

      if (!mounted) {
        return;
      }

      setState(() {
        _trips = trips.map(consoleTripToCard).toList();
        _isLoading = false;
      });

      await _loadAgencyName();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  /// The agency name is decorative, so a failure is not surfaced.
  Future<void> _loadAgencyName() async {
    try {
      final StaffAgencyProfile agency = await _console.getMyAgency();

      if (mounted) {
        setState(() => _agencyName = agency.name);
      }
    } on ApiException {
      // Keep the generic heading when the profile cannot be read.
    }
  }

  List<Map<String, dynamic>> get _filteredTrips {
    if (_selectedFilter == _all) {
      return _trips;
    }

    return _trips.where((trip) => trip['status'] == _selectedFilter).toList();
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  Future<void> _openTripDetails(Map<String, dynamic> trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgencyTripDetailsScreen(trip: trip),
      ),
    );

    // The details screen can edit the trip or its seat capacity.
    if (mounted) {
      await _loadTrips();
    }
  }

  Future<void> _openCreateTrip() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripScreen()),
    );

    if (mounted) {
      await _loadTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> trips = _filteredTrips;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency Trips'),
        actions: [
          IconButton(
            tooltip: 'Create Trip',
            onPressed: _openCreateTrip,
            icon: const Icon(Icons.add),
          ),
        ],
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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummary(context),
                      const SizedBox(height: 22),
                      _buildCreateAction(context),
                      const SizedBox(height: 18),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_errorMessage != null)
                        _buildError(context)
                      else ...[
                        _buildFilters(context),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: trips.isEmpty
                              ? _buildEmptyState(context)
                              : Column(
                                  key: ValueKey(_selectedFilter),
                                  children: trips
                                      .map(
                                        (trip) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 14,
                                          ),
                                          child: _AgencyTripCard(
                                            trip: trip,
                                            formattedPrice: _formatPrice(
                                              trip['price'] as int,
                                            ),
                                            onTap: () {
                                              _openTripDetails(trip);
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                      ],
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

  Widget _buildSummary(BuildContext context) {
    final int scheduled = _trips
        .where((trip) => trip['status'] == _scheduled)
        .length;

    final int completed = _trips
        .where((trip) => trip['status'] == _completed)
        .length;

    final int cancelled = _trips
        .where((trip) => trip['status'] == _cancelled)
        .length;

    final int inProgress = _trips
        .where((trip) => trip['status'] == _inProgress)
        .length;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.directions_bus_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _agencyName ?? 'Your agency',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_trips.length} trips',
                      style: Theme.of(context).textTheme.bodySmall,
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
                label: 'Scheduled',
                value: scheduled,
                color: AppColors.primary,
              ),
              _SummaryBadge(
                label: 'In Progress',
                value: inProgress,
                color: AppColors.warning,
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

  Widget _buildCreateAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _openCreateTrip,
        icon: const Icon(Icons.add_road_outlined),
        label: const Text('Create New Trip'),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final bool selected = filter == _selectedFilter;

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

  Widget _buildError(BuildContext context) {
    return GlassContainer(
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
            _errorMessage ?? 'Unable to load trips.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _loadTrips,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final String title = _selectedFilter == _all
        ? 'No trips'
        : 'No $_selectedFilter trips';

    return GlassContainer(
      key: ValueKey('empty-$_selectedFilter'),
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      borderRadius: 18,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus_outlined,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
          Text(
            'There are currently no trips under this status.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AgencyTripCard extends StatelessWidget {
  const _AgencyTripCard({
    required this.trip,
    required this.formattedPrice,
    required this.onTap,
  });

  final Map<String, dynamic> trip;
  final String formattedPrice;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (trip['status']) {
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

  IconData get _statusIcon {
    switch (trip['status']) {
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

  @override
  Widget build(BuildContext context) {
    final int bookedSeats = trip['bookedSeats'] as int;

    final int totalSeats = trip['totalSeats'] as int;

    final double occupancy = totalSeats == 0 ? 0 : bookedSeats / totalSeats;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip['departureCity']} → '
                      '${trip['destinationCity']}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip['id'] as String,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 13, color: _statusColor),
                    const SizedBox(width: 5),
                    Text(
                      trip['status'] as String,
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
          const SizedBox(height: 17),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _TripInformation(
                icon: Icons.calendar_today_outlined,
                value: trip['date'] as String,
              ),
              _TripInformation(
                icon: Icons.schedule_outlined,
                value:
                    '${trip['departureTime']} – '
                    '${trip['arrivalTime']}',
              ),
              _TripInformation(
                icon: Icons.event_seat_outlined,
                value: trip['travelClass'] as String,
              ),
              _TripInformation(
                icon: Icons.payments_outlined,
                value: '$formattedPrice FCFA',
              ),
            ],
          ),
          const SizedBox(height: 17),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Seat occupancy',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '$bookedSeats / $totalSeats',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: occupancy,
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripInformation extends StatelessWidget {
  const _TripInformation({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
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
