import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'admin_monitor_list.dart';

class AdminTripsScreen extends StatelessWidget {
  const AdminTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AdminMonitorList<AdminTripRow>(
      title: l.platformTrips,
      emptyMessage: 'No trip has been scheduled yet.',
      load: AdminService.instance.getTrips,
      itemBuilder: (BuildContext context, AdminTripRow trip) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.directions_bus_outlined),
          title: Text(trip.routeLabel),
          subtitle: Text(
            '${trip.agencyName ?? '—'}\n'
            '${trip.departureTime == null ? '—' : formatAdminDateTime(trip.departureTime!)}\n'
            '${formatAdminAmount(trip.price)} • '
            '${trip.bookedSeats} / ${trip.totalSeats} seats booked',
          ),
          isThreeLine: true,
          trailing: Chip(label: Text(trip.status)),
        );
      },
    );
  }
}
