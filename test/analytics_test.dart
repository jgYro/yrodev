import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yro/analytics.dart';
import 'package:yro/analytics_preferences.dart';
import 'package:yro/main.dart';
import 'package:yro/site.dart';

import 'font_loader.dart';

class RecordingAnalytics extends SiteAnalytics {
  @override
  bool available = true;
  @override
  AnalyticsConsent consent = AnalyticsConsent.unknown;
  bool fail = false;
  final events = <(String, Map<String, String>)>[];

  @override
  void setConsent(bool granted) {
    consent = granted ? AnalyticsConsent.granted : AnalyticsConsent.denied;
  }

  @override
  bool track(String event, Map<String, String> parameters) {
    if (fail) throw StateError('Analytics unavailable');
    if (consent != AnalyticsConsent.granted) return false;
    events.add((event, parameters));
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadSiteFonts);
  Future<void> launch(
    WidgetTester tester,
    RecordingAnalytics analytics, {
    double width = 1440,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(YroApp(analytics: analytics));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Declining analytics keeps contact usable without a measured event',
    (tester) async {
      final analytics = RecordingAnalytics();
      await launch(tester, analytics);
      await tester.tap(find.text('No thanks'));
      await tester.pump();
      expect(analytics.consent, AnalyticsConsent.denied);
      expect(find.byType(AnalyticsPreferences), findsNothing);
      await tester.tap(find.widgetWithText(TextButton, 'Contact'));
      await tester.pump();
      expect(analytics.events, isEmpty);
      expect(
        find.text('Email address copied: business@yro.dev'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Each desktop contact records its placement exactly once', (
    tester,
  ) async {
    final analytics = RecordingAnalytics()..setConsent(true);
    await launch(tester, analytics);
    const placements = ['header', 'working_with_yro', 'mind_country', 'footer'];
    for (var i = 0; i < placements.length; i++) {
      final contact = find.byType(EmailContact).at(i);
      await tester.ensureVisible(contact);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: contact, matching: find.byType(TextButton)),
      );
      await tester.pump();
    }
    final contacts = analytics.events
        .where((event) => event.$1 == 'contact_click')
        .toList();
    expect(contacts.map((e) => e.$2['placement']), placements);
    expect(contacts[1].$2['contact_context'], 'business');
    expect(contacts[2].$2['contact_context'], 'community');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Analytics consent controls fit at 320 pixels', (tester) async {
    final analytics = RecordingAnalytics();
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AnalyticsPreferences(
              consent: analytics.consent,
              onChoice: analytics.setConsent,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Allow analytics'));
    await tester.pump();
    expect(analytics.consent, AnalyticsConsent.granted);
    expect(analytics.events, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Contact still works if analytics throws', (tester) async {
    final analytics = RecordingAnalytics()
      ..setConsent(true)
      ..fail = true;
    await launch(tester, analytics);
    await tester.tap(find.widgetWithText(TextButton, 'Contact'));
    await tester.pump();
    expect(find.text('Email address copied: business@yro.dev'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chapter views require dwell and do not repeat on navigation', (
    tester,
  ) async {
    final analytics = RecordingAnalytics()..setConsent(true);
    await launch(tester, analytics);
    await tester.tap(find.widgetWithText(TextButton, 'What We Do'));
    await tester.pumpAndSettle();
    expect(analytics.events.where((e) => e.$1 == 'chapter_view'), isEmpty);
    await tester.pump(const Duration(seconds: 1));
    expect(
      analytics.events
          .where((e) => e.$1 == 'chapter_view')
          .single
          .$2['chapter_id'],
      'what_we_do',
    );
    await tester.tap(find.widgetWithText(TextButton, 'What We Do'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(analytics.events.where((e) => e.$1 == 'chapter_view').length, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Background time does not count toward chapter dwell', (
    tester,
  ) async {
    final analytics = RecordingAnalytics()..setConsent(true);
    await launch(tester, analytics);
    await tester.tap(find.widgetWithText(TextButton, 'What We Do'));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump(const Duration(seconds: 2));
    expect(analytics.events.where((e) => e.$1 == 'chapter_view'), isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(analytics.events.where((e) => e.$1 == 'chapter_view'), isEmpty);
    await tester.pump(const Duration(milliseconds: 100));
    expect(analytics.events.where((e) => e.$1 == 'chapter_view').length, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
