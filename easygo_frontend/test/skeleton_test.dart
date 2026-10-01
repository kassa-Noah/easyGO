import 'package:easygo_frontend/core/theme/app_theme.dart';
import 'package:easygo_frontend/shared/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The placeholders shown while a list is on its way.
///
/// Two things are worth pinning and neither is how they look: that a screen
/// gets the number of rows it asked for, and that the animation stops when the
/// reader has asked for no motion — this widget is on seventeen screens and
/// replaced a spinner on each of them, so a controller that keeps running after
/// the data lands would be a leak in a lot of places at once.
void main() {
  group('SkeletonList', () {
    testWidgets('draws the number of rows it was asked for', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonList(rows: 3)));

      // One icon block and two lines of text per row.
      expect(find.byType(SkeletonBox), findsNWidgets(9));

      await tester.pump(_sweep);
    });

    testWidgets('draws no rows when asked for none', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonList(rows: 0)));

      expect(find.byType(SkeletonBox), findsNothing);
    });

    testWidgets('builds on a theme that sets neither card nor divider colour', (
      tester,
    ) async {
      // A bare MaterialApp has null for both. This is how a screen that forgot
      // to bring the app theme would reach the widget, and a placeholder must
      // not be the thing that throws.
      await tester.pumpWidget(_wrap(const SkeletonList(rows: 1)));

      expect(tester.takeException(), isNull);

      await tester.pump(_sweep);
    });

    testWidgets('sweeps every block while motion is allowed', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonList(rows: 2)));

      final Iterable<SkeletonBox> boxes = tester.widgetList<SkeletonBox>(
        find.byType(SkeletonBox),
      );

      expect(boxes, isNotEmpty);

      // One controller, shared: a screen with six rows should not be running
      // eighteen animations to say "something is coming".
      expect(boxes.every((SkeletonBox box) => box.animation != null), isTrue);

      await tester.pump(_sweep);
    });

    testWidgets('stops moving when the reader has asked for no motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const SkeletonList(rows: 2), disableAnimations: true),
      );

      await tester.pump();

      final Iterable<SkeletonBox> boxes = tester.widgetList<SkeletonBox>(
        find.byType(SkeletonBox),
      );

      // Reduced motion drops the sweep and draws still blocks instead.
      expect(boxes, isNotEmpty);
      expect(boxes.every((SkeletonBox box) => box.animation == null), isTrue);
    });

    testWidgets('leaves no controller running when it leaves the screen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SkeletonList(rows: 2)));

      await tester.pump(_sweep);

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // A repeating controller that outlived its widget would be reported as a
      // pending timer at teardown and fail this test.
      await tester.pump(_sweep);
    });
  });

  group('SkeletonBox', () {
    testWidgets('draws still when it was given no animation', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonBox(height: 12, width: 80)));

      // Scoped to the box itself: the framework puts AnimatedBuilders of its
      // own all over the tree, so counting them globally proves nothing.
      expect(
        find.descendant(
          of: find.byType(SkeletonBox),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('the app themes', () {
    testWidgets('both carry the two colours a placeholder needs', (
      tester,
    ) async {
      for (final ThemeData theme in <ThemeData>[
        AppTheme.lightTheme,
        AppTheme.darkTheme,
      ]) {
        expect(theme.cardTheme.color, isNotNull);
        expect(theme.dividerTheme.color, isNotNull);
      }
    });
  });
}

const Duration _sweep = Duration(milliseconds: 1400);

Widget _wrap(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  );
}
