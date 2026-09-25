import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'admin_monitor_list.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AdminMonitorList<AdminBookingRow>(
      title: l.platformBookings,
      emptyMessage: 'No booking has been made yet.',
      load: AdminService.instance.getAllBookings,
      itemBuilder: (BuildContext context, AdminBookingRow booking) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.confirmation_number_outlined),
          title: Text(booking.bookingReference),
          subtitle: Text(
            '${booking.passengerName.isEmpty ? '—' : booking.passengerName} • '
            '${booking.agencyName ?? '—'}\n'
            '${booking.routeLabel}\n'
            '${formatAdminAmount(booking.totalAmount)} • '
            '${booking.numberOfSeats} '
            '${booking.numberOfSeats == 1 ? 'seat' : 'seats'}',
          ),
          isThreeLine: true,
          trailing: Chip(label: Text(booking.status)),
        );
      },
    );
  }
}
