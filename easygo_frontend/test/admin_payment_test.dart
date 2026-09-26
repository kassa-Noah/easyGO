import 'package:easygo_frontend/features/admin/models/admin_console.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> payment({
    Object? amount = 5000,
    String status = 'SUCCESSFUL',
    String method = 'SIMULATED',
    Object? paidAt = '2026-09-25T21:49:33.502Z',
    Object? providerReference,
    Map<String, dynamic>? trip,
  }) {
    return <String, dynamic>{
      'id': 'p1',
      'transactionReference': 'PAY-TEST-0001',
      'amount': amount,
      'method': method,
      'status': status,
      'providerReference': providerReference,
      'paidAt': paidAt,
      'createdAt': '2026-09-25T21:49:33.412Z',
      'booking': <String, dynamic>{
        'bookingReference': 'EG-TEST-0001',
        'status': 'CONFIRMED',
        'user': <String, dynamic>{
          'firstName': 'Claire',
          'lastName': 'Client',
          'email': 'customer@easygo.com',
        },
        'trip':
            trip ??
            <String, dynamic>{
              'agency': <String, dynamic>{'name': 'Finexs Voyages'},
              'route': <String, dynamic>{
                'originBranch': <String, dynamic>{'city': 'Yaounde'},
                'destinationBranch': <String, dynamic>{'city': 'Douala'},
              },
            },
      },
    };
  }

  group('AdminPaymentRow.fromJson', () {
    test('reads the payment, the booking, the traveller and the route', () {
      final AdminPaymentRow row = AdminPaymentRow.fromJson(payment());

      expect(row.transactionReference, 'PAY-TEST-0001');
      expect(row.amount, 5000);
      expect(row.status, 'Successful');
      expect(row.method, 'Simulated');
      expect(row.bookingReference, 'EG-TEST-0001');
      expect(row.bookingStatus, 'Confirmed');
      expect(row.customerName, 'Claire Client');
      expect(row.customerEmail, 'customer@easygo.com');
      expect(row.agencyName, 'Finexs Voyages');
      expect(row.routeLabel, 'Yaounde → Douala');
      expect(row.paidAt, isNotNull);
    });

    test('reads the amount when the API sends a decimal as a string', () {
      final AdminPaymentRow row = AdminPaymentRow.fromJson(
        payment(amount: '12500'),
      );

      expect(row.amount, 12500);
    });

    test('leaves paidAt null for a payment that never settled', () {
      // A pending or failed payment records no settlement time, and the screen
      // must not show one.
      final AdminPaymentRow row = AdminPaymentRow.fromJson(
        payment(status: 'FAILED', paidAt: null),
      );

      expect(row.status, 'Failed');
      expect(row.paidAt, isNull);
    });

    test('handles a settled payment whose settlement time was never recorded',
        () {
      // One historic row is SUCCESSFUL with a null paidAt. Nothing may invent a
      // date for it.
      final AdminPaymentRow row = AdminPaymentRow.fromJson(
        payment(status: 'SUCCESSFUL', paidAt: null),
      );

      expect(row.status, 'Successful');
      expect(row.paidAt, isNull);
    });

    test('keeps a provider reference when the provider supplied one', () {
      final AdminPaymentRow row = AdminPaymentRow.fromJson(
        payment(providerReference: 'MTN-99887766'),
      );

      expect(row.providerReference, 'MTN-99887766');
    });

    test('leaves the provider reference null for a simulated payment', () {
      final AdminPaymentRow row = AdminPaymentRow.fromJson(payment());

      expect(row.providerReference, isNull);
    });

    test('names the route from the trip when the trip carries no route', () {
      final AdminPaymentRow row = AdminPaymentRow.fromJson(
        payment(
          trip: <String, dynamic>{
            'agency': <String, dynamic>{'name': 'Finexs Voyages'},
          },
        ),
      );

      expect(row.routeLabel, 'Route not attached');
    });

    test('copes with no booking attached at all', () {
      final AdminPaymentRow row = AdminPaymentRow.fromJson(
        <String, dynamic>{
          'transactionReference': 'PAY-ORPHAN',
          'amount': '5000',
          'status': 'PENDING',
        },
      );

      expect(row.bookingReference, '');
      expect(row.customerName, '');
      expect(row.agencyName, '');
      expect(row.routeLabel, '');
    });
  });

  group('payment labels', () {
    test('names the known settlement states', () {
      expect(adminPaymentStatusLabel('PENDING'), 'Pending');
      expect(adminPaymentStatusLabel('SUCCESSFUL'), 'Successful');
      expect(adminPaymentStatusLabel('FAILED'), 'Failed');
      expect(adminPaymentStatusLabel('REFUNDED'), 'Refunded');
    });

    test('falls back to readable text for an unknown state', () {
      expect(adminPaymentStatusLabel('SOMETHING_NEW'), 'Something New');
    });

    test('names the known payment methods', () {
      expect(adminPaymentMethodLabel('SIMULATED'), 'Simulated');
      expect(adminPaymentMethodLabel('MTN_MOBILE_MONEY'), 'MTN Mobile Money');
      expect(adminPaymentMethodLabel('ORANGE_MONEY'), 'Orange Money');
    });

    test('falls back to readable text for an unknown method', () {
      expect(adminPaymentMethodLabel('WALLET_TOPUP'), 'Wallet Topup');
    });
  });
}
