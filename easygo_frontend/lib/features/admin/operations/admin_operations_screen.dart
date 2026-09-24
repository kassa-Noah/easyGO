import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';
import 'admin_bookings_screen.dart';
import 'admin_luggage_screen.dart';
import 'admin_parcels_screen.dart';
import 'admin_trips_screen.dart';

class AdminOperationsScreen extends StatelessWidget {
  const AdminOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final items = [
      (l.monitorTrips, Icons.directions_bus_outlined, const AdminTripsScreen()),
      (
        l.monitorBookings,
        Icons.confirmation_number_outlined,
        const AdminBookingsScreen(),
      ),
      (l.monitorLuggage, Icons.luggage_outlined, const AdminLuggageScreen()),
      (
        l.monitorParcels,
        Icons.inventory_2_outlined,
        const AdminParcelsScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.operationsMonitoring)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l.operationsMonitoringDescription),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(item.$2),
                  title: Text(item.$1),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item.$3),
                    );
                  },
                ),
              ),
            ),
          ),
          GlassContainer(child: Text(l.adminOperationsReadOnlyNotice)),
        ],
      ),
    );
  }
}
