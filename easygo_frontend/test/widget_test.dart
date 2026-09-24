import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/app.dart';

void main() {
  testWidgets(
    'easyGO application starts successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const EasyGoApp(),
      );

      await tester.pump();

      expect(
        find.byType(EasyGoApp),
        findsOneWidget,
      );
    },
  );
}