import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.platformBookings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.confirmation_number_outlined),
              title: const Text('BKG-DEMO-001'),
              subtitle: const Text('Marie N. • General Express'),
              trailing: Chip(label: Text(l.agencyBookingStatusLabel('Confirmed'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.confirmation_number_outlined),
              title: const Text('BKG-DEMO-002'),
              subtitle: const Text('Paul T. • Global Travel'),
              trailing: Chip(label: Text(l.agencyBookingStatusLabel('Completed'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.confirmation_number_outlined),
              title: const Text('BKG-DEMO-003'),
              subtitle: const Text('Kevin A. • General Express'),
              trailing: Chip(label: Text(l.agencyBookingStatusLabel('Cancelled'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(child: Text(l.adminOperationsReadOnlyNotice)),
        ],
      ),
    );
  }
}
