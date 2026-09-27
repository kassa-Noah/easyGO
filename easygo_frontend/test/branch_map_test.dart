import 'package:easygo_frontend/core/maps/maps_config.dart';
import 'package:easygo_frontend/shared/widgets/branch_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The map widget with no key configured.
///
/// `MapsConfig.isConfigured` is a compile-time constant, so unless the test run
/// is given `--dart-define=GOOGLE_MAPS_API_KEY=...` these exercise the state
/// every build without a key is in. That state has to be useful rather than
/// blank: it says what is missing and still shows the coordinates.
///
/// The configured state builds a `GoogleMap`, which needs a platform
/// implementation and a real key, so it is not reachable from a widget test.
void main() {
  const MapPoint douala = MapPoint(
    id: 'b1',
    title: 'Douala Main Branch',
    description: 'Akwa, Douala',
    latitude: 4.0511,
    longitude: 9.7679,
  );

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 400, child: child))),
    );
  }

  group('BranchMap without a key', () {
    testWidgets('says the map is not configured instead of drawing one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(const BranchMap(points: <MapPoint>[douala])));
      await tester.pumpAndSettle();

      if (MapsConfig.isConfigured) {
        // The run was given a key, so this state cannot be asserted.
        return;
      }

      expect(find.text('Map not configured'), findsOneWidget);
      expect(find.text('Douala Main Branch: 4.0511, 9.7679'), findsOneWidget);
    });

    testWidgets('names where the key has to go', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const BranchMap(points: <MapPoint>[douala])));
      await tester.pumpAndSettle();

      if (MapsConfig.isConfigured) {
        return;
      }

      expect(find.textContaining('GOOGLE_MAPS_API_KEY'), findsOneWidget);
    });

    testWidgets('reports an agency with no located branch', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(const BranchMap(points: <MapPoint>[])));
      await tester.pumpAndSettle();

      expect(find.text('No branch location to show'), findsOneWidget);
      expect(
        find.textContaining('no branch with coordinates'),
        findsOneWidget,
      );
    });

    testWidgets('lists a coordinate for each branch it was given', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const BranchMap(
            points: <MapPoint>[
              douala,
              MapPoint(
                id: 'b2',
                title: 'Yaounde Main Branch',
                description: 'Mvog-Mbi, Yaounde',
                latitude: 3.848,
                longitude: 11.5021,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (MapsConfig.isConfigured) {
        return;
      }

      expect(find.text('Douala Main Branch: 4.0511, 9.7679'), findsOneWidget);
      expect(find.text('Yaounde Main Branch: 3.8480, 11.5021'), findsOneWidget);
    });
  });

  group('MapsConfig', () {
    test('reports no key rather than a blank one', () {
      // A key that is only whitespace must not count as configured, or the app
      // would build a map that cannot load.
      expect(MapsConfig.apiKey, MapsConfig.apiKey.trim());
      expect(MapsConfig.isConfigured, MapsConfig.apiKey.isNotEmpty);
    });

    test('tells the reader where the key goes', () {
      expect(MapsConfig.setupHint, isNotEmpty);
      expect(MapsConfig.platformLabel, isNotEmpty);
    });
  });
}
