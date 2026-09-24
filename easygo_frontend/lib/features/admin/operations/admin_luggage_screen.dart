import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminLuggageScreen extends StatelessWidget {
  const AdminLuggageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.platformLuggage)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.luggage_outlined),
              title: const Text('LUG-DEMO-001'),
              subtitle: const Text('BKG-DEMO-001 • General Express'),
              trailing: Chip(label: Text(l.trackingStatusLabel('In Transit'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.luggage_outlined),
              title: const Text('LUG-DEMO-002'),
              subtitle: const Text('BKG-DEMO-002 • Global Travel'),
              trailing: Chip(label: Text(l.trackingStatusLabel('Delivered'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.luggage_outlined),
              title: const Text('LUG-DEMO-003'),
              subtitle: const Text('BKG-DEMO-004 • General Express'),
              trailing: Chip(label: Text(l.trackingStatusLabel('Loaded'))),
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(child: Text(l.adminOperationsReadOnlyNotice)),
        ],
      ),
    );
  }
}
