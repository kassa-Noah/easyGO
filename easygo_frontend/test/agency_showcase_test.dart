import 'package:easygo_frontend/features/agencies/models/agency.dart';
import 'package:easygo_frontend/features/agencies/models/agency_route_offer.dart';
import 'package:easygo_frontend/features/client/home/widgets/agency_showcase_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The agency strip on the customer home screen.
///
/// Two things here are worth pinning and neither is the layout: that the strip
/// moves by itself and stops when it is taken off screen, and that two agencies
/// do not come out wearing the same colour.
///
/// Both of these were broken first. The strip never started its timer, because
/// the only call that started it sat behind a "has the accessibility setting
/// changed" guard that is false on the first frame. And the colour was drawn
/// from a six-entry palette list, which put both seeded agencies on the same
/// entry — under two different hashes, so changing the hash did not help. These
/// tests are what stop either coming back.
void main() {
  // The two real ids from the database, kept verbatim because their collision is
  // the whole point.
  const String finexsId = '912184dc-5b52-4a80-b6bd-177fd01d56ea';
  const String generalExpressId = '148ae7ca-ad55-41f0-a601-b38dbd8f08f5';

  group('agencyPosterColors', () {
    test('two agencies that collide under a character sum do not collide here', () {
      expect(
        agencyPosterColors(finexsId),
        isNot(equals(agencyPosterColors(generalExpressId))),
      );
    });

    test('an agency keeps its colour between calls', () {
      // The colour is identity, so it has to be stable within a session; a
      // poster that changed on every rebuild would be decoration instead.
      expect(agencyPosterColors(finexsId), equals(agencyPosterColors(finexsId)));
    });

    test('every agency gets a usable two-stop gradient', () {
      for (final String id in <String>[
        finexsId,
        generalExpressId,
        '',
        'a',
        'not-a-uuid',
        'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      ]) {
        final List<Color> colors = agencyPosterColors(id);

        expect(colors, hasLength(2));
        expect(colors.first, isNot(equals(colors.last)));
      }
    });
  });

  group('AgencyShowcaseCarousel', () {
    testWidgets('shows a poster for the agencies it is given', (tester) async {
      await tester.pumpWidget(
        _wrap(<Agency>[
          _agency(id: finexsId, name: 'Finexs Voyages'),
          _agency(id: generalExpressId, name: 'General Express'),
        ]),
      );

      await tester.pump();

      expect(find.text('Finexs Voyages'), findsOneWidget);
    });

    testWidgets('opens the agency whose poster was tapped', (tester) async {
      Agency? opened;

      await tester.pumpWidget(
        _wrap(
          <Agency>[
            _agency(id: finexsId, name: 'Finexs Voyages'),
            _agency(id: generalExpressId, name: 'General Express'),
          ],
          onOpen: (Agency agency) {
            opened = agency;
          },
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Finexs Voyages'));

      expect(opened?.name, 'Finexs Voyages');
    });

    testWidgets('advances to the next agency on its own', (tester) async {
      await tester.pumpWidget(
        _wrap(<Agency>[
          _agency(id: finexsId, name: 'Finexs Voyages'),
          _agency(id: generalExpressId, name: 'General Express'),
        ]),
      );

      await tester.pump();

      expect(_pageOf(tester), 0);

      // The dwell, then enough for the travel animation to finish.
      await tester.pump(AgencyShowcaseCarousel.dwell);
      await tester.pump(const Duration(milliseconds: 800));

      expect(_pageOf(tester), 1);
    });

    testWidgets('holds still when given only one agency', (tester) async {
      await tester.pumpWidget(
        _wrap(<Agency>[_agency(id: finexsId, name: 'Finexs Voyages')]),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 12));

      expect(_pageOf(tester), 0);
    });

    testWidgets('cancels its timer when it leaves the screen', (tester) async {
      await tester.pumpWidget(
        _wrap(<Agency>[
          _agency(id: finexsId, name: 'Finexs Voyages'),
          _agency(id: generalExpressId, name: 'General Express'),
        ]),
      );

      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // If dispose() had left the periodic timer running, the framework would
      // report a pending timer at teardown and fail this test.
      await tester.pump(const Duration(seconds: 12));
    });

    testWidgets('a card advertises the route and fare it was given', (
      tester,
    ) async {
      const AgencyRouteOffer offer = AgencyRouteOffer(
        agencyId: finexsId,
        fromCity: 'Douala',
        toCity: 'Yaounde',
        baseFare: 5500,
      );

      await tester.pumpWidget(
        _wrap(
          <Agency>[_agency(id: finexsId, name: 'Finexs Voyages')],
          offers: <String, AgencyRouteOffer>{finexsId: offer},
        ),
      );

      await tester.pump();

      expect(find.textContaining('Douala → Yaounde'), findsOneWidget);
      expect(find.textContaining('5\u202F500 FCFA'), findsOneWidget);
    });

    testWidgets('an agency with no route still gets a card', (tester) async {
      await tester.pumpWidget(
        _wrap(<Agency>[_agency(id: finexsId, name: 'Finexs Voyages')]),
      );

      await tester.pump();

      expect(find.text('Finexs Voyages'), findsOneWidget);
      expect(find.textContaining('FCFA'), findsNothing);
    });
  });

  group('AgencyRouteOffer', () {
    // The shape the API actually returns — baseFare included as a string,
    // because Prisma serialises Decimal columns that way.
    Map<String, dynamic> payload({Object? fare = '6000'}) => <String, dynamic>{
      'baseFare': fare,
      'estimatedDurationMinutes': 285,
      'originBranch': <String, dynamic>{
        'agencyId': 'agency-1',
        'city': 'Bafoussam',
      },
      'destinationBranch': <String, dynamic>{
        'agencyId': 'agency-1',
        'city': 'Yaounde',
      },
    };

    test('reads a route whose fare arrives as a string', () {
      final AgencyRouteOffer? offer = AgencyRouteOffer.fromJson(payload());

      expect(offer, isNotNull);
      expect(offer!.agencyId, 'agency-1');
      expect(offer.fromCity, 'Bafoussam');
      expect(offer.toCity, 'Yaounde');
      expect(offer.baseFare, 6000);
    });

    test('writes a fare the way a price is written', () {
      final AgencyRouteOffer? offer = AgencyRouteOffer.fromJson(
        payload(fare: '5500'),
      );

      expect(offer!.formattedFare, '5\u202F500 FCFA');
    });

    test('describes the journey time', () {
      final AgencyRouteOffer? offer = AgencyRouteOffer.fromJson(payload());

      expect(offer!.formattedDuration, '4h 45min');
    });

    test('a route it cannot read costs one card, not the screen', () {
      // Null rather than throwing, so one bad route cannot take out the home
      // screen that is trying to advertise it.
      expect(AgencyRouteOffer.fromJson(payload(fare: null)), isNull);
      expect(AgencyRouteOffer.fromJson(payload(fare: '0')), isNull);
      expect(AgencyRouteOffer.fromJson(payload(fare: 'not a price')), isNull);
      expect(AgencyRouteOffer.fromJson(<String, dynamic>{}), isNull);
    });
  });
}

double? _pageOf(WidgetTester tester) {
  return tester.widget<PageView>(find.byType(PageView)).controller?.page;
}

Widget _wrap(
  List<Agency> agencies, {
  Map<String, AgencyRouteOffer> offers = const <String, AgencyRouteOffer>{},
  void Function(Agency agency)? onOpen,
}) {
  return MaterialApp(
    home: Scaffold(
      body: AgencyShowcaseCarousel(
        agencies: agencies,
        offers: offers,
        onOpen: onOpen ?? (Agency agency) {},
      ),
    ),
  );
}

Agency _agency({required String id, required String name}) {
  return Agency(
    id: id,
    name: name,
    description: null,
    phone: null,
    email: null,
    logoUrl: null,
    website: null,
    isActive: true,
    branches: const <AgencyBranch>[],
  );
}
