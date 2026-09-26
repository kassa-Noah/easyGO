import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'admin_monitor_list.dart';

/// Every payment taken on the platform.
///
/// `GET /admin/payments` already existed and had no caller, so an
/// administrator could see bookings and trips but not whether any of them had
/// actually been paid for. The row is built from the booking the payment
/// belongs to, which is what makes it readable: the reference alone says
/// nothing about which journey it settles.
class AdminPaymentsScreen extends StatelessWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AdminMonitorList<AdminPaymentRow>(
      title: l.platformPayments,
      emptyMessage: 'No payment has been taken yet.',
      load: AdminService.instance.getAllPayments,
      itemBuilder: (BuildContext context, AdminPaymentRow payment) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            payment.status == 'Successful'
                ? Icons.check_circle_outline
                : payment.status == 'Failed'
                ? Icons.error_outline
                : Icons.hourglass_empty,
          ),
          title: Text(
            '${payment.amount.round()} FCFA • ${payment.method}',
          ),
          subtitle: Text(
            '${payment.transactionReference}\n'
            '${payment.agencyName.isEmpty ? 'Agency not recorded' : payment.agencyName}'
            '${payment.routeLabel.isEmpty ? '' : ' • ${payment.routeLabel}'}\n'
            '${payment.bookingReference.isEmpty ? 'Booking not attached' : payment.bookingReference}'
            ' • ${payment.customerName.isEmpty ? 'Traveller not recorded' : payment.customerName}'
            '${_settledLabel(payment)}',
          ),
          isThreeLine: true,
          trailing: Chip(label: Text(payment.status)),
        );
      },
    );
  }

  /// Nothing is claimed about when a payment settled unless it has: a pending
  /// or failed payment carries no `paidAt`.
  static String _settledLabel(AdminPaymentRow payment) {
    final DateTime? paidAt = payment.paidAt;

    if (paidAt == null) {
      return '';
    }

    final String day = paidAt.day.toString().padLeft(2, '0');
    final String month = paidAt.month.toString().padLeft(2, '0');

    return ' • paid $day/$month/${paidAt.year}';
  }
}
