import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'manage_luggage_status_screen.dart';

class AgencyLuggageDetailsScreen
    extends StatelessWidget {
  const AgencyLuggageDetailsScreen({
    super.key,
    required this.luggage,
  });

  final Map<String, dynamic> luggage;

  static const List<String> _statuses = [
    'Registered',
    'Received by Agency',
    'Loaded',
    'In Transit',
    'Arrived',
    'Ready for Collection',
    'Delivered',
  ];

  int get _currentStatusIndex {
    final int index = _statuses.indexOf(
      luggage['status'] as String,
    );

    return index < 0 ? 0 : index;
  }

  double get _progress {
    return _currentStatusIndex /
        (_statuses.length - 1);
  }

  bool get _canManage =>
      luggage['status'] != 'Delivered';

  Color _statusColor(String status) {
    switch (status) {
      case 'Registered':
        return AppColors.textSecondary;
      case 'Received by Agency':
        return AppColors.primary;
      case 'Loaded':
        return AppColors.primaryDark;
      case 'In Transit':
        return AppColors.warning;
      case 'Arrived':
        return AppColors.secondary;
      case 'Ready for Collection':
        return AppColors.secondaryDark;
      case 'Delivered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _openStatusManagement(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ManageLuggageStatusScreen(
          luggage: luggage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final String status =
        luggage['status'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Luggage Details',
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
            padding:
                const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              34,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 850,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      context,
                      status,
                    ),
                    const SizedBox(height: 18),
                    _buildTrackingProgress(
                      context,
                    ),
                    const SizedBox(height: 18),
                    _buildLuggageInformation(
                      context,
                    ),
                    const SizedBox(height: 18),
                    _buildTravelerInformation(
                      context,
                    ),
                    const SizedBox(height: 18),
                    _buildJourneyInformation(
                      context,
                    ),
                    const SizedBox(height: 18),
                    _buildManagementSection(
                      context,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String status,
  ) {
    final Color color =
        _statusColor(status);

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.luggage_outlined,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  luggage['id'] as String,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  luggage['description']
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
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingProgress(
    BuildContext context,
  ) {
    final String status =
        luggage['status'] as String;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Progress',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  status,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
              ),
              Text(
                '${(_progress * 100).round()}%',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor:
                  AppColors.primary
                      .withValues(
                alpha: 0.10,
              ),
            ),
          ),
          const SizedBox(height: 22),
          ...List.generate(
            _statuses.length,
            (index) {
              final String itemStatus =
                  _statuses[index];

              final bool completed =
                  index <
                      _currentStatusIndex;

              final bool current =
                  index ==
                      _currentStatusIndex;

              return _TrackingStage(
                status: itemStatus,
                completed: completed,
                current: current,
                showConnector:
                    index <
                        _statuses.length -
                            1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLuggageInformation(
    BuildContext context,
  ) {
    return _SectionCard(
      title: 'Luggage Information',
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.tag_outlined,
            label: 'Luggage Reference',
            value: luggage['id'] as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons
                .description_outlined,
            label: 'Description',
            value:
                luggage['description']
                    as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.scale_outlined,
            label: 'Weight',
            value:
                '${luggage['weight']} kg',
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons
                .confirmation_number_outlined,
            label: 'Booking Reference',
            value:
                luggage['bookingReference']
                    as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon:
                Icons.qr_code_outlined,
            label: 'Ticket Reference',
            value:
                luggage['ticketReference']
                    as String,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelerInformation(
    BuildContext context,
  ) {
    return _SectionCard(
      title: 'Traveler Information',
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Traveler',
            value:
                luggage['clientName']
                    as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value:
                luggage['clientPhone']
                    as String,
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyInformation(
    BuildContext context,
  ) {
    return _SectionCard(
      title: 'Journey Information',
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.route_outlined,
            label: 'Route',
            value:
                '${luggage['departureCity']} → '
                '${luggage['destinationCity']}',
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon:
                Icons.directions_bus_outlined,
            label: 'Trip Reference',
            value:
                luggage['tripId'] as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons
                .calendar_today_outlined,
            label: 'Travel Date',
            value:
                luggage['travelDate']
                    as String,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.schedule_outlined,
            label: 'Departure Time',
            value:
                luggage['departureTime']
                    as String,
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(
    BuildContext context,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Management',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            _canManage
                ? 'Advance this luggage item to its next valid tracking status.'
                : 'This luggage has been delivered and its tracking lifecycle is complete.',
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
                Icons
                    .published_with_changes_outlined,
              ),
              label: const Text(
                'Update Tracking Status',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStage
    extends StatelessWidget {
  const _TrackingStage({
    required this.status,
    required this.completed,
    required this.current,
    required this.showConnector,
  });

  final String status;
  final bool completed;
  final bool current;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final Color color = completed
        ? AppColors.success
        : current
            ? AppColors.primary
            : AppColors.textLight;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.12,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                ),
              ),
              child: Icon(
                completed
                    ? Icons.check
                    : current
                        ? Icons
                            .radio_button_checked
                        : Icons.circle_outlined,
                size: 15,
                color: color,
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 27,
                color: completed
                    ? AppColors.success
                        .withValues(
                          alpha: 0.45,
                        )
                    : Theme.of(context)
                        .dividerColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 4,
            ),
            child: Text(
              status,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: current
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: current
                        ? AppColors.primary
                        : null,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard
    extends StatelessWidget {
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
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _DetailRow
    extends StatelessWidget {
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
            color: AppColors.primary
                .withValues(
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