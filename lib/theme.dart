// Theme engine: maps the three AppThemeModes to full ThemeData.
part of 'main.dart';

ThemeData buildAppTheme(AppThemeMode mode) {
  final baseTheme = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
  );

  switch (mode) {
    case AppThemeMode.banana:
      return baseTheme.copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        primaryColor: const Color(0xFFFFD93D),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFD93D),
          secondary: Color(0xFF2C2C2E),
          surface: Colors.white,
          onSurface: Color(0xFF2C2C2E),
        ),
        cardColor: Colors.white,
      );
    case AppThemeMode.dark:
      return baseTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD93D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD93D),
          secondary: Color(0xFF2C2C2E),
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
          onSecondary: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
      );
    case AppThemeMode.system:
      return baseTheme.copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        primaryColor: const Color(0xFF007AFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007AFF),
          secondary: Color(0xFF1C1C1E),
          surface: Colors.white,
        ),
        cardColor: Colors.white,
      );
  }
}
