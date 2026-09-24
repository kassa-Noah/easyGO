import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class AgencyDashboardScreen extends StatelessWidget {
  const AgencyDashboardScreen({
    super.key,
    this.onOpenOperations,
    this.onOpenMessages,
  });

  final VoidCallback? onOpenOperations;
  final VoidCallback? onOpenMessages;

  static const List<Map<String, dynamic>> _statistics = [
    {'label': 'Trips', 'value': 6, 'icon': Icons.directions_bus_outlined},
    {
      'label': 'Bookings',
      'value': 24,
      'icon': Icons.confirmation_number_outlined,
    },
    {'label': 'Luggage', 'value': 12, 'icon': Icons.luggage_outlined},
    {'label': 'Parcels', 'value': 8, 'icon': Icons.inventory_2_outlined},
  ];

  static const List<Map<String, dynamic>> _upcomingTrips = [
    {
      'departureCity': 'Yaoundé',
      'destinationCity': 'Douala',
      'departureTime': '07:00',
      'arrivalTime': '11:00',
      'travelClass': 'VIP',
      'bookedSeats': 32,
      'totalSeats': 50,
    },
    {
      'departureCity': 'Yaoundé',
      'destinationCity': 'Bafoussam',
      'departureTime': '09:30',
      'arrivalTime': '13:30',
      'travelClass': 'Classic',
      'bookedSeats': 18,
      'totalSeats': 40,
    },
  ];

  static const List<Map<String, dynamic>> _recentActivity = [
    {
      'title': 'New booking received',
      'description': 'Yaoundé → Douala',
      'time': '10 min ago',
      'icon': Icons.confirmation_number_outlined,
    },
    {
      'title': 'Parcel status updated',
      'description': 'PAR-DEMO-001 • In Transit',
      'time': '25 min ago',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'title': 'New client message',
      'description': 'A client sent a new message.',
      'time': '40 min ago',
      'icon': Icons.chat_bubble_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 26),
                        _buildSectionTitle(context, 'Today'),
                        const SizedBox(height: 14),
                        _buildStatistics(context),
                        const SizedBox(height: 28),
                        _buildSectionTitle(context, 'Quick Actions'),
                        const SizedBox(height: 14),
                        _buildQuickActions(context),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          context,
                          title: 'Upcoming Trips',
                          actionLabel: 'View all',
                          onPressed: onOpenOperations,
                        ),
                        const SizedBox(height: 14),
                        ..._upcomingTrips.map(
                          (trip) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _UpcomingTripCard(trip: trip),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSectionTitle(context, 'Recent Activity'),
                        const SizedBox(height: 14),
                        _buildRecentActivity(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.directions_bus_rounded,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agency Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'General Express',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Agency notifications will be connected later.'),
              ),
            );
          },
          icon: const Badge(
            smallSize: 8,
            child: Icon(Icons.notifications_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns;

        if (constraints.maxWidth >= 760) {
          columns = 4;
        } else {
          columns = 2;
        }

        const double spacing = 12;

        final double itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _statistics.map((statistic) {
            return SizedBox(
              width: itemWidth,
              child: _StatisticCard(
                label: statistic['label'] as String,
                value: statistic['value'] as int,
                icon: statistic['icon'] as IconData,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 650;

        final double itemWidth = wide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                title: 'Create Trip',
                description: 'Add a new interurban trip schedule.',
                icon: Icons.add_road_outlined,
                onTap: onOpenOperations,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                title: 'View Bookings',
                description: 'Review bookings made with your agency.',
                icon: Icons.confirmation_number_outlined,
                onTap: onOpenOperations,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                title: 'Manage Luggage',
                description: 'View and update traveler luggage status.',
                icon: Icons.luggage_outlined,
                onTap: onOpenOperations,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                title: 'Client Messages',
                description: 'Open conversations with your clients.',
                icon: Icons.chat_bubble_outline,
                onTap: onOpenMessages,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      borderRadius: 18,
      child: Column(
        children: List.generate(_recentActivity.length, (index) {
          final Map<String, dynamic> activity = _recentActivity[index];

          return Column(
            children: [
              _ActivityRow(
                title: activity['title'] as String,
                description: activity['description'] as String,
                time: activity['time'] as String,
                icon: activity['icon'] as IconData,
              ),
              if (index != _recentActivity.length - 1)
                Divider(height: 1, color: Theme.of(context).dividerColor),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required VoidCallback? onPressed,
  }) {
    return Row(
      children: [
        Expanded(child: _buildSectionTitle(context, title)),
        if (onPressed != null)
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(height: 16),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 17,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.secondary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}

class _UpcomingTripCard extends StatelessWidget {
  const _UpcomingTripCard({required this.trip});

  final Map<String, dynamic> trip;

  @override
  Widget build(BuildContext context) {
    final int bookedSeats = trip['bookedSeats'] as int;
    final int totalSeats = trip['totalSeats'] as int;

    final double occupancy = totalSeats == 0 ? 0 : bookedSeats / totalSeats;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${trip['departureCity']} → '
                  '${trip['destinationCity']}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip['travelClass'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Text(
                '${trip['departureTime']} – '
                '${trip['arrivalTime']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$bookedSeats / $totalSeats seats',
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
          const SizedBox(height: 7),
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

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
