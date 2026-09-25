import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'admin_monitor_list.dart';

class AdminParcelsScreen extends StatelessWidget {
  const AdminParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AdminMonitorList<AdminParcelRow>(
      title: l.platformParcels,
      emptyMessage: 'No parcel has been registered yet.',
      load: AdminService.instance.getAllParcels,
      itemBuilder: (BuildContext context, AdminParcelRow parcel) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text(
            parcel.description == null || parcel.description!.isEmpty
                ? parcel.trackingNumber
                : parcel.description!,
          ),
          subtitle: Text(
            '${parcel.trackingNumber} • ${parcel.agencyName ?? '—'}\n'
            '${parcel.routeLabel} • for '
            '${parcel.recipientName.isEmpty ? '—' : parcel.recipientName}'
            '${parcel.weightKg == null ? '' : ' • ${parcel.weightKg} kg'}',
          ),
          isThreeLine: true,
          trailing: Chip(label: Text(parcel.status)),
        );
      },
    );
  }
}
