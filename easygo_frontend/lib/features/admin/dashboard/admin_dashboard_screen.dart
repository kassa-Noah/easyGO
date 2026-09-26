import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../services/admin_service.dart';
import '../../notifications/services/notification_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback onOpenAgencies;
  final VoidCallback onOpenUsers;
  final VoidCallback onOpenOperations;
  final VoidCallback onOpenRoutes;

  const AdminDashboardScreen({
    super.key,
    required this.onOpenAgencies,
    required this.onOpenUsers,
    required this.onOpenOperations,
    required this.onOpenRoutes,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _admin = AdminService.instance;

  AdminStatistics? _statistics;
  List<AdminAccount> _recentAccounts = <AdminAccount>[];
  int _unreadNotifications = 0;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final AdminDashboard dashboard = await _admin.getDashboard();

      // The badge is decorative, so failing to read it must not stop the page
      // from rendering.
      int unread = 0;

      try {
        unread = await NotificationService.instance.getUnreadCount();
      } on ApiException {
        unread = 0;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _statistics = dashboard.statistics;
        _recentAccounts = dashboard.newestAccounts;
        _unreadNotifications = unread;
        _isLoading = false;
      });
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
            _errorMessage ?? 'Unable to load the platform overview.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // The counters start at zero so the grid can be built unconditionally; the
    // loading state is shown instead of the grid until the API answers.
    final AdminStatistics s =
        _statistics ?? AdminStatistics.fromJson(<String, dynamic>{});

    final List<(String, String, IconData)> stats = <(String, String, IconData)>[
      (l.agencies, formatAdminCount(s.agenciesTotal), Icons.business_outlined),
      (l.users, formatAdminCount(s.usersTotal), Icons.people_outline),
      (
        l.bookings,
        formatAdminCount(s.bookingsTotal),
        Icons.confirmation_number_outlined,
      ),
      (
        l.activeTrips,
        formatAdminCount(s.tripsScheduled),
        Icons.directions_bus_outlined,
      ),
      (l.luggage, formatAdminCount(s.luggageTotal), Icons.luggage_outlined),
      (l.parcels, formatAdminCount(s.parcelsTotal), Icons.inventory_2_outlined),
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
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            icon: Badge(
              isLabelVisible: _unreadNotifications > 0,
              label: Text('$_unreadNotifications'),
              child: const Icon(Icons.notifications_outlined),
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
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_errorMessage != null)
                  _buildError(context)
                else ...[
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
                  onTap: widget.onOpenAgencies,
                ),
                const SizedBox(height: 10),
                _Action(
                  icon: Icons.people_outline,
                  title: l.manageUsers,
                  subtitle: l.manageUsersDescription,
                  onTap: widget.onOpenUsers,
                ),
                const SizedBox(height: 10),
                _Action(
                  icon: Icons.monitor_heart_outlined,
                  title: l.monitorOperations,
                  subtitle: l.monitorOperationsDescription,
                  onTap: widget.onOpenOperations,
                ),
                const SizedBox(height: 10),
                _Action(
                  icon: Icons.alt_route_outlined,
                  title: l.manageRoutes,
                  subtitle: l.manageRoutesDescription,
                  onTap: widget.onOpenRoutes,
                ),
                const SizedBox(height: 28),
                Text(
                  'Agencies by state',
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
                      _Status(
                        formatAdminCount(s.agenciesActive),
                        'Active',
                        Icons.check_circle_outline,
                      ),
                      _Status(
                        formatAdminCount(s.agenciesInactive),
                        'Suspended',
                        Icons.block_outlined,
                      ),
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
                      if (_recentAccounts.isEmpty)
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('No account has registered yet.'),
                        )
                      else
                        for (
                          int index = 0;
                          index < _recentAccounts.length;
                          index++
                        ) ...[
                          if (index > 0) const Divider(),
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(_recentAccounts[index].fullName),
                            subtitle: Text(
                              '${_recentAccounts[index].email}'
                              '${_recentAccounts[index].createdAt == null ? '' : ' • registered ${formatAdminDate(_recentAccounts[index].createdAt!)}'}',
                            ),
                            trailing: Text(_recentAccounts[index].role),
                          ),
                        ],
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
