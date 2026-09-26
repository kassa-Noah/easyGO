import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../agencies/admin_agencies_screen.dart';
import '../dashboard/admin_dashboard_screen.dart';
import '../operations/admin_operations_screen.dart';
import '../profile/admin_profile_screen.dart';
import '../routes/admin_routes_screen.dart';
import '../users/admin_users_screen.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _selectedIndex = 0;

  void _select(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openRoutes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminRoutesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final pages = [
      AdminDashboardScreen(
        onOpenAgencies: () => _select(1),
        onOpenUsers: () => _select(2),
        onOpenOperations: () => _select(3),
        // Routes have no tab of their own, so this opens the screen directly
        // rather than switching to one.
        onOpenRoutes: _openRoutes,
      ),
      const AdminAgenciesScreen(),
      const AdminUsersScreen(),
      const AdminOperationsScreen(),
      const AdminProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: l.adminDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.business_outlined),
            selectedIcon: const Icon(Icons.business),
            label: l.agencies,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l.users,
          ),
          NavigationDestination(
            icon: const Icon(Icons.monitor_heart_outlined),
            selectedIcon: const Icon(Icons.monitor_heart),
            label: l.operations,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.profile,
          ),
        ],
      ),
    );
  }
}
