import 'package:flutter/material.dart';

import 'analytics.dart';
import 'site.dart';
import 'site_theme.dart';

void main() => runApp(const YroApp());

class YroApp extends StatelessWidget {
  const YroApp({super.key, this.analytics = const PlatformAnalytics()});

  final SiteAnalytics analytics;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Yro LLC | Software, Security, AI & Media',
    debugShowCheckedModeBanner: false,
    theme: buildSiteTheme(),
    home: YroSite(analytics: analytics),
  );
}
