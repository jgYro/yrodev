import 'package:flutter/material.dart';

const canvasBlack = Color(0xFF050505);
const surface = Color(0xFF101012);
const surfaceAlt = Color(0xFF0B0B0D);
const ink = Color(0xFFFFFFFF);
const muted = Color(0xFFB8B8C1);
const line = Color(0xFF303037);
const bloodRed = Color(0xFF7E1025);
const bloodRedEdge = Color(0xFFA8344B);
const purple = Color(0xFFB49BD6);
const deepPurple = Color(0xFF4D286B);
const sansFont = 'IBM Plex Sans';
const monoFont = 'IBM Plex Mono';

ThemeData buildSiteTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: canvasBlack,
  canvasColor: canvasBlack,
  fontFamily: sansFont,
  colorScheme: const ColorScheme.dark(
    primary: ink,
    onPrimary: canvasBlack,
    primaryContainer: bloodRed,
    onPrimaryContainer: ink,
    secondary: purple,
    onSecondary: canvasBlack,
    secondaryContainer: deepPurple,
    onSecondaryContainer: ink,
    surface: surface,
    onSurface: ink,
    onSurfaceVariant: muted,
    outline: line,
    error: Color(0xFFFF7B91),
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: purple.withValues(alpha: 0.35),
    selectionHandleColor: purple,
    cursorColor: ink,
  ),
  dividerColor: line,
  textButtonTheme: TextButtonThemeData(
    style:
        TextButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(fontFamily: monoFont, fontSize: 12),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return purple.withValues(alpha: 0.25);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return purple.withValues(alpha: 0.12);
            }
            return null;
          }),
        ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: ink,
      focusColor: purple.withValues(alpha: 0.25),
      hoverColor: purple.withValues(alpha: 0.12),
      shape: const RoundedRectangleBorder(),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: ink,
    contentTextStyle: TextStyle(fontFamily: sansFont, color: canvasBlack),
  ),
);
