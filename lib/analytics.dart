import 'dart:convert';

import 'analytics_target_stub.dart'
    if (dart.library.js_interop) 'analytics_target_web.dart'
    as target;

enum AnalyticsConsent { unknown, granted, denied }

/// The site's small analytics boundary. Tests can supply an in-memory recorder.
abstract class SiteAnalytics {
  const SiteAnalytics();

  bool get available;
  AnalyticsConsent get consent;
  void setConsent(bool granted);
  bool track(String event, Map<String, String> parameters);
}

class PlatformAnalytics extends SiteAnalytics {
  const PlatformAnalytics();

  @override
  bool get available => target.available();

  @override
  AnalyticsConsent get consent => switch (target.consent()) {
    'granted' => AnalyticsConsent.granted,
    'denied' => AnalyticsConsent.denied,
    _ => AnalyticsConsent.unknown,
  };

  @override
  void setConsent(bool granted) => target.setConsent(granted);

  @override
  bool track(String event, Map<String, String> parameters) =>
      target.track(event, jsonEncode(parameters));
}

const chapterIds = {
  'Who We Are': 'who_we_are',
  'What We Do': 'what_we_do',
  'What We’ve Done': 'what_weve_done',
  'Why We Do It': 'why_we_do_it',
};
