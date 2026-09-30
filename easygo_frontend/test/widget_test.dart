import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/app.dart';
import 'package:easygo_frontend/features/auth/screens/onboarding_screen.dart';
import 'package:easygo_frontend/features/auth/screens/splash_screen.dart';

void main() {
  setUp(() {
    // The splash reads the stored session before deciding where to go, and the
    // secure-storage plugin has no implementation under `flutter test`: the call
    // never completes rather than failing, so the screen would sit on its
    // spinner forever.
    //
    // The package ships an in-memory platform for exactly this. An empty store
    // is a fresh install, which is the case below.
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      <String, String>{},
    );
  });
  testWidgets('easyGO application starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EasyGoApp());

    // The localization delegates resolve asynchronously, so
    // one more frame is needed before the first screen builds.
    await tester.pump();

    expect(find.byType(EasyGoApp), findsOneWidget);

    // The splash screen is the first screen shown.
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('splash screen advances to onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EasyGoApp());

    await tester.pump();

    // Let the splash timer elapse so that no
    // timers are left pending when the test ends.
    await tester.pump(const Duration(seconds: 3));

    // Deliberately not `pumpAndSettle`. The splash shows a circular progress
    // indicator, which schedules a frame forever, so settling is impossible
    // while it is on screen — the test only ever passed because the route change
    // used to happen in the same frame as the timer. It no longer does, because
    // the splash checks the stored session before deciding where to go.
    //
    // A few bounded frames instead: one for the awaited session check to
    // continue past, and one or two for the new route to build.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
