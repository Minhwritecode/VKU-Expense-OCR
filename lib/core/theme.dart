part of '../main.dart';

class AppColors {
  static const ink = Color(0xFF152238);
  static const blue = Color(0xFF2F5BEA);
  static const blueDark = Color(0xFF2045B5);
  static const cream = Color(0xFFF8F6F0);
  static const paper = Color(0xFFFFFDF8);
  static const orange = Color(0xFFF08A4B);
  static const mint = Color(0xFF77C7B2);
  static const lavender = Color(0xFFB3A1E6);
  static const red = Color(0xFFE66A6A);
}

const _darkPreview = bool.fromEnvironment('LEDGERLY_DARK_PREVIEW');
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => _darkPreview ? ThemeMode.dark : ThemeMode.light,
);

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: brightness,
    surface: dark ? const Color(0xFF101722) : AppColors.paper,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'LedgerlySans',
    colorScheme: scheme.copyWith(
      primary: dark ? const Color(0xFF87A5FF) : AppColors.blue,
      onPrimary: Colors.white,
      secondary: dark ? const Color(0xFFFFB07C) : AppColors.orange,
      surface: dark ? const Color(0xFF101722) : AppColors.paper,
    ),
    scaffoldBackgroundColor: dark ? const Color(0xFF101722) : AppColors.cream,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? const Color(0xFF182332) : AppColors.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1A2636) : const Color(0xFFF1EFE9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: dark ? const Color(0xFF121C2A) : AppColors.paper,
      indicatorColor: dark ? const Color(0xFF263E7E) : const Color(0xFFE1E8FF),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: dark ? const Color(0xFF121C2A) : AppColors.paper,
      indicatorColor: dark ? const Color(0xFF263E7E) : const Color(0xFFE1E8FF),
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.12,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, height: 1.25),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, height: 1.3),
      bodyLarge: TextStyle(height: 1.45),
      bodyMedium: TextStyle(height: 1.5),
      bodySmall: TextStyle(height: 1.4),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, height: 1.25),
    ),
  );
}
