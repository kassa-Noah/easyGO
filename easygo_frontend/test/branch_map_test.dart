import 'package:easygo_frontend/shared/widgets/branch_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

/// The branch map.
///
/// This used to test the states around a missing Google Maps key. There is no
/// key now — the tiles come from OpenStreetMap — so what is worth testing is
/// that the map is actually built, and that the two things OpenStreetMap
/// requires of a client are set rather than left at flutter_map's defaults.
///
/// The tiles themselves are fetched over the network and are not asserted on;
/// these check the widget's own configuration.
void main() {
  const MapPoint douala = MapPoint(
    id: 'b1',
    title: 'Douala Main Branch',
    description: 'Akwa, Douala',
    latitude: 4.0511,
    longitude: 9.7679,
  );

  const MapPoint yaounde = MapPoint(
    id: 'b2',
    title: 'Yaounde Main Branch',
    description: 'Mvog-Mbi, Yaounde',
    latitude: 3.848,
    longitude: 11.5021,
  );

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 400, child: child))),
    );
  }

  Future<void> pumpMap(WidgetTester tester, List<MapPoint> points) async {
    await tester.pumpWidget(wrap(BranchMap(points: points)));

    // Not `pumpAndSettle`: the tiles are a network fetch that never settles in a
    // test, and the assertions below are about the widget tree, not the imagery.
    await tester.pump();
  }

  TileLayer tileLayerOf(WidgetTester tester) {
    return tester.widget<TileLayer>(find.byType(TileLayer));
  }

  group('BranchMap with a located branch', () {
    testWidgets('builds a map', (WidgetTester tester) async {
      await pumpMap(tester, const <MapPoint>[douala]);

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);
    });

    testWidgets('draws one marker per branch', (WidgetTester tester) async {
      await pumpMap(tester, const <MapPoint>[douala, yaounde]);

      final MarkerLayer layer = tester.widget<MarkerLayer>(
        find.byType(MarkerLayer),
      );

      expect(layer.markers, hasLength(2));
    });

    testWidgets('credits OpenStreetMap, which its tiles require', (
      WidgetTester tester,
    ) async {
      await pumpMap(tester, const <MapPoint>[douala]);

      // The credit has to be on screen, not behind a button: OpenStreetMap's
      // tile policy asks for attribution, and a credit nobody opens is not
      // really shown.
      expect(find.byType(SimpleAttributionWidget), findsOneWidget);
      expect(find.text('OpenStreetMap contributors'), findsOneWidget);
      expect(find.byType(RichAttributionWidget), findsNothing);
    });

    testWidgets('asks the public tile server for tiles', (
      WidgetTester tester,
    ) async {
      await pumpMap(tester, const <MapPoint>[douala]);

      expect(
        tileLayerOf(tester).urlTemplate,
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      );
    });

    testWidgets('identifies the app rather than leaving it as unknown', (
      WidgetTester tester,
    ) async {
      // flutter_map defaults this to 'unknown' and warns about it, because the
      // OpenStreetMap tile policy asks clients to say who they are. Leaving the
      // default is a way to be blocked without knowing why.
      //
      // The name is not a field on TileLayer; flutter_map folds it into the
      // tile provider's User-Agent header, so that is what is checked here.
      await pumpMap(tester, const <MapPoint>[douala]);

      final Map<String, String> headers = tileLayerOf(tester).tileProvider
          .headers;

      expect(headers['User-Agent'], contains('com.example.easygo_frontend'));
    });

    testWidgets('takes its tiles from wherever it is told', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const BranchMap(
            points: <MapPoint>[douala],
            tileServerUrl: 'https://tiles.example.com/{z}/{x}/{y}.png',
          ),
        ),
      );
      await tester.pump();

      expect(
        tileLayerOf(tester).urlTemplate,
        'https://tiles.example.com/{z}/{x}/{y}.png',
      );
    });

    testWidgets('no longer claims the map is not configured', (
      WidgetTester tester,
    ) async {
      await pumpMap(tester, const <MapPoint>[douala]);

      expect(find.textContaining('Map not configured'), findsNothing);
      expect(find.textContaining('GOOGLE_MAPS_API_KEY'), findsNothing);
    });
  });

  group('BranchMap with nothing to place', () {
    testWidgets('reports an agency with no located branch', (
      WidgetTester tester,
    ) async {
      await pumpMap(tester, const <MapPoint>[]);

      expect(find.text('No branch location to show'), findsOneWidget);
      expect(find.textContaining('no branch with coordinates'), findsOneWidget);
    });

    testWidgets('builds no map at all rather than an empty one', (
      WidgetTester tester,
    ) async {
      await pumpMap(tester, const <MapPoint>[]);

      expect(find.byType(FlutterMap), findsNothing);
    });
  });
}
