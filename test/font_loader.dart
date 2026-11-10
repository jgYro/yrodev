import 'package:flutter/services.dart';

/// Exercise the real typography rather than Flutter tests' oversized Ahem font.
Future<void> loadSiteFonts() async {
  for (final family in {
    'IBM Plex Sans': [
      'IBMPlexSans-Regular',
      'IBMPlexSans-Medium',
      'IBMPlexSans-SemiBold',
    ],
    'IBM Plex Mono': ['IBMPlexMono-Regular'],
  }.entries) {
    final loader = FontLoader(family.key);
    for (final file in family.value) {
      loader.addFont(rootBundle.load('assets/fonts/ibm-plex/$file.ttf'));
    }
    await loader.load();
  }
}
