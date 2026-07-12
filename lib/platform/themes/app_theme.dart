import 'package:flutter/material.dart';

class AppTheme {
  //====================================================
  // MEMO 01 — MAIN BRAND COLORS
  // Edit only these colors to change whole app style
  //====================================================

  static const Color bgTop = Color(0xFF062B5B);

  static const Color bgBottom = Color(0xFF020817);

  static const Color surface = Color(0xFF102A59);

  static const Color border = Color(0x22FFFFFF);

  static const Color primaryAccent = Color(0xFF14F1FF);

  static const Color secondaryAccent = Color(0xFFD93CFF);

  //====================================================
  // MEMO 02 — COMMON PAGE BACKGROUND
  // Used in pages:
  // decoration: AppTheme.pageBackground
  //====================================================

  static const BoxDecoration pageBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        bgTop,
        bgBottom,
      ],
    ),
  );

  //====================================================
  // MEMO 03 — LIGHT THEME
  // Edit light mode appearance
  //====================================================

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: true,
      elevation: 0,
    ),
    cardColor: Colors.white,
    dividerColor: Colors.black12,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),
  );

  //====================================================
  // MEMO 04 — DARK THEME
  // MAIN BBeez One UI STYLE
  //====================================================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    primarySwatch: Colors.blue,

    //================================================
    // MEMO 05 — SCAFFOLD
    // Transparent so gradient shows
    //================================================

    scaffoldBackgroundColor: Colors.transparent,

    //================================================
    // MEMO 06 — APP BAR
    // Controls top title bar
    //================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    //================================================
    // MEMO 07 — CARD STYLE
    // Settings / Notes / Support cards
    //================================================

    cardColor: surface,

    dividerColor: border,

    //================================================
    // MEMO 08 — TEXT COLORS
    //================================================

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
      ),
    ),

    //================================================
    // MEMO 09 — ICON STYLE
    //================================================

    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

    //================================================
    // MEMO 10 — SWITCH STYLE
    //================================================

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(
        primaryAccent,
      ),
      trackColor: WidgetStateProperty.all(
        primaryAccent.withValues(alpha: .4),
      ),
    ),

    //================================================
    // MEMO 11 — BOTTOM NAVIGATION
    //================================================

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    //================================================
    // MEMO 12 — FAB
    //================================================

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryAccent,
    ),
  );

  //====================================================
  // MEMO 13 — GLASS CARD DECORATION
  // Use for profile/settings cards
  //====================================================

  static BoxDecoration glassCard = BoxDecoration(
    color: Colors.white.withValues(alpha: .05),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: border,
    ),
  );
}
