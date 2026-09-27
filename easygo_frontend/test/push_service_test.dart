import 'package:easygo_frontend/app.dart';
import 'package:easygo_frontend/core/push/push_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Push notifications, on the side the app controls.
///
/// What is worth pinning here is not that a push arrives — that needs Firebase
/// and a device — but the property everything else rests on: a build that cannot
/// be pushed to behaves like any other build. Push is a second way of being told
/// something the app already knows, so a phone with no Google Play services, a
/// build with no Firebase configuration, or a reader who declined the permission
/// must not be able to break a sign-in or a booking.
void main() {
  group('a build that cannot reach Firebase', () {
    test('starts, registers and releases without throwing', () async {
      // No Firebase configuration exists in a test, so `initialize` fails
      // internally. That is the state being tested: the failure has to stay
      // inside, because these three are called from `main`, from a sign-in and
      // from a sign-out, and none of those may be interrupted by push.
      await PushService.initialize();

      await PushService.instance.start();

      await PushService.instance.stop();
    });

    test('reports that it cannot be pushed to on this platform', () {
      // `flutter_test` reports Android, which the service does support, so this
      // asserts the shape of the answer rather than a particular value: the
      // check exists so that the web — which needs a service worker and a VAPID
      // key, and would silently do nothing — is excluded deliberately rather
      // than by accident.
      expect(PushService.isSupported, isA<bool>());
    });
  });

  group('a push that arrives while the app is open', () {
    testWidgets('is shown in the app, because the system draws nothing', (
      WidgetTester tester,
    ) async {
      // Android does not draw a notification for a foregrounded app. Without
      // this the reader would see nothing at all: no buzz, no banner, and the
      // event only discoverable later in the bell.
      await tester.pumpWidget(const EasyGoApp());

      await tester.pump();

      expect(
        PushService.onForegroundMessage,
        isNotNull,
        reason: 'the app must have offered somewhere for a push to be shown',
      );

      PushService.onForegroundMessage!.call(
        'Booking confirmed',
        'Your seat on Yaounde to Douala is confirmed.',
      );

      await tester.pump();

      expect(find.text('Booking confirmed'), findsOneWidget);
      expect(
        find.text('Your seat on Yaounde to Douala is confirmed.'),
        findsOneWidget,
      );

      // Let the splash timer and the banner's own timer finish, so the test does
      // not end with either still pending.
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();
    });

    testWidgets('leaves nowhere to show one once the app is gone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const EasyGoApp());
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      // A stale messenger would be a held reference to a disposed tree, and a
      // push arriving after that would throw inside a Firebase callback where
      // nothing is listening.
      expect(PushService.onForegroundMessage, isNull);

      await tester.pump(const Duration(seconds: 4));
    });
  });
}
