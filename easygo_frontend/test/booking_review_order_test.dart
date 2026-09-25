import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/core/localization/app_localizations.dart';
import 'package:easygo_frontend/core/theme/app_theme.dart';
import 'package:easygo_frontend/features/client/booking/booking_review_screen.dart';
import 'package:easygo_frontend/features/trips/models/trip.dart';

/// The booking summary must end with the amount the traveller actually pays.
///
/// A door-to-door booking also lists estimated taxi fares. Those estimates are
/// larger than the interurban fare and are paid to the driver, so they are not
/// part of the charge. They used to be listed *below* the amount payable, which
/// left a taxi estimate as the last amount above "Continue to payment" rather
/// than the amount the button charges.
///
/// The screen is a scrolling summary above a sticky footer that repeats the
/// amount payable next to the button, so the two regions are asserted
/// separately. Within the summary the amount payable must be the last amount;
/// in the footer it must be the last amount before the button.
///
/// The interurban fare row and the amount payable row carry the same number for
/// a single passenger, so rows are located by their labels, not by their values.

const AppLocalizations l10n = AppLocalizations(Locale('en'));

const String kPayable = '5,000 FCFA';

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

Widget _screen({required String bookingMode}) {
  return MaterialApp(
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
    home: BookingReviewScreen(
      agency: <String, dynamic>{'id': 'agency-1', 'name': 'Finexs Voyages'},
      trip: _trip(),
      bookingMode: bookingMode,
      departureCity: 'Yaoundé',
      destinationCity: 'Douala',
      pickupLocation: 'Mvan',
      finalDestination: 'Bonabéri',
      travelDate: DateTime(2026, 10, 10),
      passengers: 1,
      luggage: 1,
    ),
  );
}

bool _insideSummary(Element element) {
  bool found = false;

  element.visitAncestorElements((Element ancestor) {
    if (ancestor.widget is SingleChildScrollView) {
      found = true;
      return false;
    }

    return true;
  });

  return found;
}

double _centre(Element element) {
  final RenderBox box = element.renderObject! as RenderBox;
  return box.localToGlobal(Offset.zero).dy + box.size.height / 2;
}

/// Vertical centres of the laid-out texts equal to [text], by region.
List<double> _centres(
  WidgetTester tester,
  String text, {
  required bool inSummary,
}) {
  return find
      .text(text)
      .evaluate()
      .where((element) => _insideSummary(element) == inSummary)
      .map(_centre)
      .toList();
}

/// Every amount on screen, with its region and vertical centre.
List<({String text, bool inSummary, double y})> _amounts(WidgetTester tester) {
  final List<({String text, bool inSummary, double y})> amounts =
      <({String text, bool inSummary, double y})>[];

  for (final Element element in find.byType(Text).evaluate()) {
    final String? data = (element.widget as Text).data;

    if (data != null && data.contains('FCFA')) {
      amounts.add((
        text: data,
        inSummary: _insideSummary(element),
        y: _centre(element),
      ));
    }
  }

  return amounts;
}

double _lowestInSummary(WidgetTester tester, String label) {
  return _centres(
    tester,
    label,
    inSummary: true,
  ).reduce((a, b) => a > b ? a : b);
}

void main() {
  group('booking review price summary', () {
    testWidgets('places the amount payable after every other summary amount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_screen(bookingMode: 'door_to_door'));
      await tester.pump();

      final double payable = _lowestInSummary(tester, l10n.amountPayable);

      for (final String label in <String>[
        l10n.interurbanFareForPassengers(1),
        l10n.estimatedTaxiFares,
        l10n.pickupTaxiFareLabel,
        l10n.destinationTaxiFareLabel,
      ]) {
        final List<double> centres = _centres(tester, label, inSummary: true);

        expect(centres, isNotEmpty, reason: '"$label" should be in the summary');

        expect(
          centres.reduce((a, b) => a > b ? a : b),
          lessThan(payable),
          reason: '"$label" must appear above the amount payable',
        );
      }
    });

    testWidgets('shows no amount after the amount payable in the summary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_screen(bookingMode: 'door_to_door'));
      await tester.pump();

      final double payable = _lowestInSummary(tester, l10n.amountPayable);

      // Only the amount payable itself may sit at or below its own row, so the
      // breakdown cannot end on a taxi estimate.
      final List<String> trailing = _amounts(tester)
          .where((amount) => amount.inSummary && amount.y > payable)
          .map((amount) => amount.text)
          .where((text) => text != kPayable)
          .toList();

      expect(
        trailing,
        isEmpty,
        reason: 'the summary must end on the amount payable',
      );
    });

    testWidgets('ends the footer with the amount payable, then the button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_screen(bookingMode: 'door_to_door'));
      await tester.pump();

      final List<double> footerAmounts = _centres(
        tester,
        l10n.amountPayable,
        inSummary: false,
      );

      expect(
        footerAmounts,
        hasLength(1),
        reason: 'the sticky footer shows the amount payable once',
      );

      expect(
        _amounts(tester)
            .where((amount) => !amount.inSummary)
            .map((amount) => amount.text)
            .toSet(),
        <String>{kPayable},
        reason: 'the footer must carry no other amount',
      );

      final RenderBox button = tester.renderObject<RenderBox>(
        find.byType(ElevatedButton),
      );
      final double buttonY =
          button.localToGlobal(Offset.zero).dy + button.size.height / 2;

      expect(
        footerAmounts.single,
        lessThan(buttonY),
        reason: 'the amount payable must sit directly above the button',
      );
    });

    testWidgets('shows no taxi estimates on a standard interurban booking', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_screen(bookingMode: 'interurban'));
      await tester.pump();

      for (final String label in <String>[
        l10n.estimatedTaxiFares,
        l10n.pickupTaxiFareLabel,
        l10n.destinationTaxiFareLabel,
      ]) {
        expect(
          find.text(label),
          findsNothing,
          reason: '"$label" belongs to a door-to-door booking',
        );
      }

      expect(find.text('5,500 FCFA'), findsNothing);
      expect(find.text('2,500 FCFA'), findsNothing);
      expect(find.text('3,000 FCFA'), findsNothing);

      // The fare row and the payable row in the summary, plus the footer.
      expect(find.text(kPayable), findsNWidgets(3));
    });

    testWidgets('never folds the taxi estimates into the amount charged', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_screen(bookingMode: 'door_to_door'));
      await tester.pump();

      // 5,000 fare + 5,500 taxi estimates must never appear as a single amount.
      expect(find.text('10,500 FCFA'), findsNothing);
      expect(find.text('8,000 FCFA'), findsNothing);

      // The estimates are still shown, as estimates only.
      expect(find.text('5,500 FCFA'), findsOneWidget);

      // Fare row, payable row, footer row: every one of them the fare alone.
      expect(find.text(kPayable), findsNWidgets(3));
    });
  });
}
