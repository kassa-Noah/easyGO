import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/app.dart';
import 'package:easygo_frontend/features/auth/screens/onboarding_screen.dart';
import 'package:easygo_frontend/features/auth/screens/splash_screen.dart';

void main() {
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

    // Let the splash timer elapse so that no
    // timers are left pending when the test ends.
    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
