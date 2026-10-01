import 'package:easygo_frontend/features/agencies/models/agency.dart';
import 'package:easygo_frontend/features/agencies/models/agency_route_offer.dart';
import 'package:easygo_frontend/features/client/agencies/agency_details_screen.dart';
import 'package:easygo_frontend/features/client/home/widgets/agency_showcase_carousel.dart';
import 'package:easygo_frontend/features/client/trips/trip_details_screen.dart';
import 'package:easygo_frontend/shared/widgets/optional_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The flights between a card and the screen it opens.
///
/// A [Hero] whose tag is wrong on one end does not throw, does not warn and
/// does not fail anything — the page transition simply goes back to being a
/// page transition. That is exactly the kind of change nobody notices, which is
/// why the two ends are pinned here rather than left to matching literals.
void main() {
  const String finexsId = '912184dc-5b52-4a80-b6bd-177fd01d56ea';
  const String generalExpressId = '148ae7ca-ad55-41f0-a601-b38dbd8f08f5';

  group('AgencyDetailsScreen.avatarTag', () {
    test('two cards opening one agency do not name the same flight', () {
      // The rail and the list both open the same agency, and both are in the
      // same tree while they do it. One tag for both is a duplicate-hero error
      // on every tap.
      expect(
        AgencyDetailsScreen.avatarTag('rail', finexsId),
        isNot(equals(AgencyDetailsScreen.avatarTag('list', finexsId))),
      );
    });

    test('one card opening two agencies does not name the same flight', () {
      expect(
        AgencyDetailsScreen.avatarTag('list', finexsId),
        isNot(equals(AgencyDetailsScreen.avatarTag('list', generalExpressId))),
      );
    });

    test('the rail names its own flight with its own constant', () {
      // Pins the rail against the home screen, which opens the details screen
      // under AgencyShowcaseCarousel.heroCard. Changing that constant in one
      // place only would quietly stop the avatar growing.
      expect(AgencyShowcaseCarousel.heroCard, 'rail');

      expect(
        AgencyDetailsScreen.avatarTag(
          AgencyShowcaseCarousel.heroCard,
          finexsId,
        ),
        contains(finexsId),
      );
    });
  });

  group('TripDetailsScreen.tileTag', () {
    test('two cards opening one booking do not name the same flight', () {
      expect(
        TripDetailsScreen.tileTag('list', 'EG-0001'),
        isNot(equals(TripDetailsScreen.tileTag('search', 'EG-0001'))),
      );
    });

    test('one card opening two bookings does not name the same flight', () {
      expect(
        TripDetailsScreen.tileTag('list', 'EG-0001'),
        isNot(equals(TripDetailsScreen.tileTag('list', 'EG-0002'))),
      );
    });
  });

  group('OptionalHero', () {
    testWidgets('flies when it was given a tag', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OptionalHero(
            tag: 'a-flight',
            child: SizedBox(key: Key('tile'), width: 10, height: 10),
          ),
        ),
      );

      expect(find.byKey(const Key('tile')), findsOneWidget);
      expect(tester.widget<Hero>(find.byType(Hero)).tag, 'a-flight');
    });

    testWidgets('draws in place when it was not', (tester) async {
      // Every journey into a screen that is not a card tap lands here: a
      // notification, a refresh, a cold open. A hero with no counterpart on the
      // outgoing route is a flight from nowhere.
      await tester.pumpWidget(
        const MaterialApp(
          home: OptionalHero(
            tag: null,
            child: SizedBox(key: Key('tile'), width: 10, height: 10),
          ),
        ),
      );

      expect(find.byKey(const Key('tile')), findsOneWidget);
      expect(find.byType(Hero), findsNothing);
    });
  });

  group('the rail card', () {
    testWidgets('raises the avatar the details screen is told to expect', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgencyShowcaseCarousel(
              agencies: <Agency>[_agency(finexsId, 'Finexs Voyages')],
              offers: const <String, AgencyRouteOffer>{},
              onOpen: (Agency agency) {},
            ),
          ),
        ),
      );

      await tester.pump();

      final List<Hero> heroes = tester
          .widgetList<Hero>(find.byType(Hero))
          .toList();

      expect(heroes, hasLength(1));

      expect(
        heroes.single.tag,
        AgencyDetailsScreen.avatarTag(
          AgencyShowcaseCarousel.heroCard,
          finexsId,
        ),
      );
    });
  });
}

Agency _agency(String id, String name) {
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
