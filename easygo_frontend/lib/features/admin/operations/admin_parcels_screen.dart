import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminParcelsScreen extends StatelessWidget {
  const AdminParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.platformParcels)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('PAR-DEMO-001'),
              subtitle: const Text('Marie N. • General Express'),
              trailing: Chip(label: Text(l.trackingStatusLabel('In Transit'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('PAR-DEMO-002'),
              subtitle: const Text('Paul T. • Global Travel'),
              trailing: Chip(label: Text(l.trackingStatusLabel('Delivered'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('PAR-DEMO-003'),
              subtitle: const Text('Alice K. • General Express'),
              trailing: Chip(label: Text(l.trackingStatusLabel('Received by Agency'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(child: Text(l.adminOperationsReadOnlyNotice)),
        ],
      ),
    );
  }
}
