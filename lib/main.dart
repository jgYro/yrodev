import 'package:flutter/material.dart';

import 'site.dart';

void main() => runApp(const YroApp());

class YroApp extends StatelessWidget {
  const YroApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Yro LLC | Software, Security, AI & Media',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: navy,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mint,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Arial',
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    ),
    home: const YroSite(),
  );
}
