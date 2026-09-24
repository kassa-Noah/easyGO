import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../dashboard/agency_dashboard_screen.dart';
import '../messages/agency_conversations_screen.dart';
import '../operations/agency_operations_screen.dart';
import '../profile/agency_profile_screen.dart';

class AgencyMainNavigation extends StatefulWidget {
  const AgencyMainNavigation({
    super.key,
  });

  @override
  State<AgencyMainNavigation> createState() =>
      _AgencyMainNavigationState();
}

class _AgencyMainNavigationState
    extends State<AgencyMainNavigation> {
  int _selectedIndex = 0;

  void _selectPage(int index) {
    if (index < 0 || index > 3) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context);

    final List<Widget> pages = [
      AgencyDashboardScreen(
        onOpenOperations: () {
          _selectPage(1);
        },
        onOpenMessages: () {
          _selectPage(2);
        },
      ),
      const AgencyOperationsScreen(),
      const AgencyConversationsScreen(),
      const AgencyProfileScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 250,
        ),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(
            _selectedIndex,
          ),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        destinations: [
          NavigationDestination(
            icon: const Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: const Icon(
              Icons.dashboard,
              color: AppColors.primary,
            ),
            label:
                localizations.agencyDashboard,
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.grid_view_outlined,
            ),
            selectedIcon: const Icon(
              Icons.grid_view_rounded,
              color: AppColors.primary,
            ),
            label: localizations.operations,
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.chat_bubble_outline,
            ),
            selectedIcon: const Icon(
              Icons.chat_bubble,
              color: AppColors.primary,
            ),
            label: localizations.messages,
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.business_outlined,
            ),
            selectedIcon: const Icon(
              Icons.business,
              color: AppColors.primary,
            ),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }
}