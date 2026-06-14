import 'package:flutter/material.dart';

const _primary = Color(0xFFFE2C55);
const _secondary = Color(0xFF25F4EE);

const _lightSurface = Color(0xFFFFFFFF);
const _lightBackground = Color(0xFFF7F8FA);
const _lightOnSurface = Color(0xFF222222);
const _lightOnSurfaceVariant = Color(0xFF6B7280);
const _lightOutline = Color(0xFFE5E7EB);

const _darkSurface = Color(0xFF121212);
const _darkBackground = Color(0xFF000000);
const _darkOnSurface = Color(0xFFE6E8EB);
const _darkOnSurfaceVariant = Color(0xFFA1A6AD);
const _darkOutline = Color(0xFF2A2A2A);

ThemeData buildLightTheme({String? fontFamily}) {
  const colorScheme = ColorScheme.light(
    primary: _primary,
    onPrimary: Colors.white,
    secondary: _secondary,
    onSecondary: Colors.black,
    surface: _lightSurface,
    onSurface: _lightOnSurface,
    onSurfaceVariant: _lightOnSurfaceVariant,
    outline: _lightOutline,
    surfaceTint: Colors.transparent,
  );

  return _buildBase(
    colorScheme: colorScheme,
    scaffoldColor: _lightBackground,
    surface: _lightSurface,
    outline: _lightOutline,
    onSurface: _lightOnSurface,
    onSurfaceVariant: _lightOnSurfaceVariant,
    fontFamily: fontFamily,
  );
}

ThemeData buildDarkTheme({String? fontFamily}) {
  const colorScheme = ColorScheme.dark(
    primary: _primary,
    onPrimary: Colors.white,
    secondary: _secondary,
    onSecondary: Colors.black,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    onSurfaceVariant: _darkOnSurfaceVariant,
    outline: _darkOutline,
    surfaceTint: Colors.transparent,
  );

  return _buildBase(
    colorScheme: colorScheme,
    scaffoldColor: _darkBackground,
    surface: _darkSurface,
    outline: _darkOutline,
    onSurface: _darkOnSurface,
    onSurfaceVariant: _darkOnSurfaceVariant,
    fontFamily: fontFamily,
  );
}

ThemeData _buildBase({
  required ColorScheme colorScheme,
  required Color scaffoldColor,
  required Color surface,
  required Color outline,
  required Color onSurface,
  required Color onSurfaceVariant,
  String? fontFamily,
}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldColor,
    fontFamily: fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 48,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: onSurface,
        fontFamily: fontFamily,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
    ),
    dividerTheme: DividerThemeData(color: outline, thickness: 0.5, space: 0.5),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface, fontFamily: fontFamily),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface, fontFamily: fontFamily),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface, fontFamily: fontFamily),
      bodyLarge: TextStyle(fontSize: 15, color: onSurface, fontFamily: fontFamily),
      bodyMedium: TextStyle(fontSize: 14, color: onSurface, fontFamily: fontFamily),
      bodySmall: TextStyle(fontSize: 12, color: onSurfaceVariant, fontFamily: fontFamily),
    ),
  );
}
