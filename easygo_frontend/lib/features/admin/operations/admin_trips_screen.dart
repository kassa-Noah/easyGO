import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminTripsScreen extends StatelessWidget {
  const AdminTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.platformTrips)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.directions_bus_outlined),
              title: const Text('TRIP-DEMO-001'),
              subtitle: const Text('Yaoundé → Douala • General Express'),
              trailing: Chip(label: Text(l.agencyTripStatusLabel('Scheduled'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.directions_bus_outlined),
              title: const Text('TRIP-DEMO-002'),
              subtitle: const Text('Yaoundé → Bafoussam • General Express'),
              trailing: Chip(label: Text(l.agencyTripStatusLabel('Scheduled'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.directions_bus_outlined),
              title: const Text('TRIP-DEMO-003'),
              subtitle: const Text('Douala → Yaoundé • Global Travel'),
              trailing: Chip(label: Text(l.agencyTripStatusLabel('Completed'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(child: Text(l.adminOperationsReadOnlyNotice)),
        ],
      ),
    );
  }
}
