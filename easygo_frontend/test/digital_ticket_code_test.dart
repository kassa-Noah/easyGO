import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:easygo_frontend/core/localization/app_localizations.dart';
import 'package:easygo_frontend/core/theme/app_theme.dart';
import 'package:easygo_frontend/features/client/booking/digital_ticket_screen.dart';
import 'package:easygo_frontend/features/trips/models/trip.dart';

/// The ticket invites the traveller to present it for verification.
///
/// For that to mean anything, the code on it has to carry the payload the
/// backend stored on the ticket. It used to draw a decorative QR glyph, which
/// looks right on screen and scans as nothing, so these tests check the rendered
/// code rather than the widget tree: the package keeps the encoded string in a
/// private field, so the observable property is that the picture it draws
/// depends on the payload.

/// The exact shape the backend returns for `qrCodeData`.
const String kQrCodeData =
    '{"type":"EASYGO_DIGITAL_TICKET",'
    '"ticketNumber":"TKT-MUHHUC0I-XD7O6P",'
    '"bookingId":"3d964f85-18b3-447c-8bfe-72b80cad344c"}';

const String kOtherQrCodeData =
    '{"type":"EASYGO_DIGITAL_TICKET",'
    '"ticketNumber":"TKT-AAAAAAA-BBBBBB",'
    '"bookingId":"11111111-2222-3333-4444-555555555555"}';

Trip _trip() {
  return Trip(
    id: 'trip-1',
    departureTime: DateTime(2026, 10, 10, 8, 30),
    arrivalTime: DateTime(2026, 10, 10, 13, 30),
    price: 5000,
    totalSeats: 40,
    availableSeats: 12,
    status: 'SCHEDULED',
    agencyId: 'agency-1',
    routeId: 'route-1',
    vehicleId: 'vehicle-1',
    agencyName: 'Finexs Voyages',
    originCity: 'Yaoundé',
    destinationCity: 'Douala',
    originBranchName: 'Yaoundé Main',
    destinationBranchName: 'Douala Main',
    originBranchAddress: 'Mvan',
    destinationBranchAddress: 'Bonabéri',
    distanceKm: 250,
    estimatedDurationMinutes: 300,
    vehicleRegistrationNumber: 'LT-1234-AB',
    vehicleModel: 'Coaster',
    vehicleBrand: 'Toyota',
    vehicleCapacity: 40,
  );
}

Widget _screen({required String qrCodeData}) {
  return RepaintBoundary(
    key: const Key('ticket-root'),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: DigitalTicketScreen(
        agency: <String, dynamic>{'id': 'agency-1', 'name': 'Finexs Voyages'},
        trip: _trip(),
        bookingMode: 'interurban_only',
        departureCity: 'Yaoundé',
        destinationCity: 'Douala',
        travelDate: DateTime(2026, 10, 10),
        passengers: 1,
        luggage: 0,
        totalAmount: 5000,
        paymentMethod: 'MTN Mobile Money',
        bookingReference: 'EG-MUHHTYRB-AKLKLR',
        ticketReference: 'TKT-MUHHUC0I-XD7O6P',
        qrCodeData: qrCodeData,
      ),
    ),
  );
}

/// Rasterises the ticket and returns the bytes of the code it drew.
Future<Uint8List> _renderTicket(WidgetTester tester, String qrCodeData) async {
  await tester.pumpWidget(_screen(qrCodeData: qrCodeData));
  await tester.pumpAndSettle();

  // The code sits below the fold, and an off-screen part of a scroll view is
  // not painted, so it has to be brought into view before the capture.
  await tester.ensureVisible(find.byType(QrImageView));
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(const Key('ticket-root')))
          as RenderRepaintBoundary;

  Uint8List? bytes;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage();
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    bytes = data?.buffer.asUint8List();
    image.dispose();
  });

  expect(bytes, isNotNull, reason: 'the ticket should rasterise');

  return bytes!;
}

void main() {
  group('digital ticket code', () {
    testWidgets('draws a code carrying the payload the backend stored', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_screen(qrCodeData: kQrCodeData));
      await tester.pump();

      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('draws a different code for a different payload', (
      WidgetTester tester,
    ) async {
      final Uint8List mine = await _renderTicket(tester, kQrCodeData);
      final Uint8List other = await _renderTicket(tester, kOtherQrCodeData);

      expect(
        mine,
        isNot(equals(other)),
        reason:
            'the drawn code must depend on the payload, or the ticket carries '
            'a picture that scans as nothing',
      );
    });

    testWidgets('draws the same code for the same payload', (
      WidgetTester tester,
    ) async {
      final Uint8List first = await _renderTicket(tester, kQrCodeData);
      final Uint8List second = await _renderTicket(tester, kQrCodeData);

      expect(first, equals(second));
    });

    testWidgets('shows the ticket number for verification by hand', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_screen(qrCodeData: kQrCodeData));
      await tester.pump();

      expect(find.text('TKT-MUHHUC0I-XD7O6P'), findsWidgets);
    });

    testWidgets('falls back to a symbol when the ticket has no payload', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_screen(qrCodeData: ''));
      await tester.pump();

      expect(find.byType(QrImageView), findsNothing);
      expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
    });
  });
}
