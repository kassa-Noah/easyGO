import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'admin_monitor_list.dart';

class AdminLuggageScreen extends StatelessWidget {
  const AdminLuggageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AdminMonitorList<AdminLuggageRow>(
      title: l.platformLuggage,
      emptyMessage: 'No luggage has been registered yet.',
      load: AdminService.instance.getAllLuggage,
      itemBuilder: (BuildContext context, AdminLuggageRow luggage) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.luggage_outlined),
          title: Text(
            luggage.description == null || luggage.description!.isEmpty
                ? luggage.trackingNumber
                : luggage.description!,
          ),
          subtitle: Text(
            '${luggage.trackingNumber} • ${luggage.agencyName ?? '—'}\n'
            '${luggage.bookingReference ?? '—'} • '
            '${luggage.passengerName == null || luggage.passengerName!.isEmpty ? '—' : luggage.passengerName}'
            '${luggage.weightKg == null ? '' : ' • ${luggage.weightKg} kg'}',
          ),
          isThreeLine: true,
          trailing: Chip(label: Text(luggage.status)),
        );
      },
    );
  }
}
