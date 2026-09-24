import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../profile/client_profile_screen.dart';
import '../tracking/tracking_home_screen.dart';
import '../trips/my_trips_screen.dart';
import 'client_home_screen.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ClientHomeScreen(),
    MyTripsScreen(),
    TrackingHomeScreen(),
    ClientProfileScreen(),
  ];

  void _changePage(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changePage,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.confirmation_num_outlined),
            selectedIcon: const Icon(Icons.confirmation_num),
            label: l10n.trips,
          ),
          NavigationDestination(
            icon: const Icon(Icons.location_searching),
            selectedIcon: const Icon(Icons.location_on),
            label: l10n.track,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
