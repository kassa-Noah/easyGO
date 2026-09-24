import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';
import '../notifications/admin_notifications_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final VoidCallback onOpenAgencies;
  final VoidCallback onOpenUsers;
  final VoidCallback onOpenOperations;

  const AdminDashboardScreen({
    super.key,
    required this.onOpenAgencies,
    required this.onOpenUsers,
    required this.onOpenOperations,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final stats = [
      (l.agencies, '12', Icons.business_outlined),
      (l.users, '1,248', Icons.people_outline),
      (l.bookings, '326', Icons.confirmation_number_outlined),
      (l.activeTrips, '18', Icons.directions_bus_outlined),
      (l.luggage, '84', Icons.luggage_outlined),
      (l.parcels, '57', Icons.inventory_2_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminDashboard),
        actions: [
          IconButton(
            tooltip: l.notifications,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminNotificationsScreen(),
                ),
              );
            },
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_outlined,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.welcomeAdministrator,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(l.adminWelcomeDescription),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  l.platformOverview,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850 ? 3 : 2;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: constraints.maxWidth < 500
                            ? 1.3
                            : 1.8,
                      ),
                      itemBuilder: (_, index) {
                        final item = stats[index];
                        return GlassContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(item.$3, color: AppColors.primary),
                              const Spacer(),
                              Text(
                                item.$2,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(item.$1),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  l.quickActions,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _Action(
                  icon: Icons.business_outlined,
                  title: l.manageAgencies,
                  subtitle: l.manageAgenciesDescription,
                  onTap: onOpenAgencies,
                ),
                const SizedBox(height: 10),
                _Action(
                  icon: Icons.people_outline,
                  title: l.manageUsers,
                  subtitle: l.manageUsersDescription,
                  onTap: onOpenUsers,
                ),
                const SizedBox(height: 10),
                _Action(
                  icon: Icons.monitor_heart_outlined,
                  title: l.monitorOperations,
                  subtitle: l.monitorOperationsDescription,
                  onTap: onOpenOperations,
                ),
                const SizedBox(height: 28),
                Text(
                  l.agencyVerification,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  child: Wrap(
                    spacing: 28,
                    runSpacing: 18,
                    children: [
                      _Status('9', l.verified, Icons.verified_outlined),
                      _Status('2', l.pending, Icons.hourglass_top),
                      _Status('1', l.suspended, Icons.block_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l.recentActivity,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.business_outlined),
                        title: Text(l.newAgencyRegistered),
                        subtitle: const Text('Central Voyage'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.verified_outlined),
                        title: Text(l.agencyVerificationCompleted),
                        subtitle: const Text('General Express'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_add_alt_1_outlined),
                        title: Text(l.newUserRegistered),
                        subtitle: const Text('USR-DEMO-1248'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.security_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.adminAuthorizationNotice)),
                    ],
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

class _Action extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _Status(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}
