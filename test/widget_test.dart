import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yro/main.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('Page lays out without overflow at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const YroApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Security operations & automation'), findsOneWidget);
      expect(find.text('Applied research & prototyping'), findsOneWidget);
      expect(find.text('Secure AI integration'), findsOneWidget);
      expect(find.text('MEDIA'), findsOneWidget);
    });
  }

  testWidgets(
    'Desktop chapter navigation opens the portfolio and returns home',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const YroApp());
      await tester.tap(find.widgetWithText(TextButton, 'What We’ve Done'));
      await tester.pumpAndSettle();
      expect(find.text('Apps we’ve made.').hitTestable(), findsOneWidget);
      await tester.ensureVisible(find.text('Back to top'));
      await tester.tap(find.text('Back to top'));
      await tester.pumpAndSettle();
      expect(find.text('View capabilities').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Mobile menu closes after navigating to Appalachian roots', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const YroApp());
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Why We Do It'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Open menu'), findsOneWidget);
    expect(find.byTooltip('Close menu'), findsNothing);
    expect(find.text('Mind Country').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
