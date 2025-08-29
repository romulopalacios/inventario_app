import 'package:flutter/material.dart';

/// Paleta de colores profesional y seria para aplicación empresarial
class AppColors {
  // Colores primarios - Azul marino corporativo
  static const Color primary = Color(0xFF1E3A5F); // Azul marino profesional
  static const Color primaryLight = Color(0xFF2B5085); // Azul marino más claro
  static const Color primaryDark = Color(0xFF142B45); // Azul marino más oscuro

  // Colores secundarios - Azul grisáceo elegante
  static const Color secondary = Color(0xFF4A6B8A); // Azul grisáceo
  static const Color secondaryLight = Color(0xFF6B8CAD); // Azul grisáceo claro
  static const Color secondaryDark = Color(0xFF35516B); // Azul grisáceo oscuro

  // Color de acento - Verde corporativo
  static const Color accent = Color(0xFF2C5F2D); // Verde profesional
  static const Color accentLight = Color(0xFF388E3C); // Verde más claro
  static const Color accentDark = Color(0xFF1B4332); // Verde oscuro

  // Colores neutros sofisticados
  static const Color neutral50 = Color(0xFFFAFBFC); // Casi blanco
  static const Color neutral100 = Color(0xFFF5F7FA); // Gris muy claro
  static const Color neutral200 = Color(0xFFE8ECEF); // Gris claro
  static const Color neutral300 = Color(0xFFD1D9E0); // Gris medio claro
  static const Color neutral400 = Color(0xFFB0BCC9); // Gris medio
  static const Color neutral500 = Color(0xFF8C9BAB); // Gris
  static const Color neutral600 = Color(0xFF6C7B87); // Gris oscuro
  static const Color neutral700 = Color(0xFF4A5462); // Gris muy oscuro
  static const Color neutral800 = Color(0xFF2E3339); // Casi negro
  static const Color neutral900 = Color(0xFF1A1D23); // Negro suave

  // Colores funcionales
  static const Color success = Color(0xFF0F9D58); // Verde éxito profesional
  static const Color successLight = Color(0xFF81C784); // Verde éxito claro
  static const Color warning = Color(0xFFF4B942); // Ámbar profesional
  static const Color warningLight = Color(0xFFFFB74D); // Ámbar claro
  static const Color error = Color(0xFFD93025); // Rojo profesional
  static const Color errorLight = Color(0xFFE57373); // Rojo claro
  static const Color info = Color(0xFF1A73E8); // Azul información
  static const Color infoLight = Color(0xFF64B5F6); // Azul información claro
}

/// Sistema de espaciado profesional
class AppSpacing {
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Métodos utilitarios
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}

/// Sistema de bordes redondeados
class AppRadius {
  static const double none = 0.0;
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double full = 999.0;

  // Métodos utilitarios
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
  static BorderRadius all(double radius) => BorderRadius.circular(radius);
}

/// Sistema de sombras profesional
class AppShadow {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 8),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];
}

/// Sistema de elevación
class AppElevation {
  static const double level0 = 0.0;
  static const double level1 = 2.0;
  static const double level2 = 4.0;
  static const double level3 = 8.0;
  static const double level4 = 12.0;
  static const double level5 = 16.0;
}

/// Sistema de animaciones
class AppAnimation {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
}

/// Tamaños de iconos
class AppIconSize {
  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 40.0;
  static const double xxl = 48.0;
}

/// Extensiones para ColorScheme
extension ColorSchemeExtension on ColorScheme {
  Color get neutralLightest => AppColors.neutral50;
  Color get neutralLight => AppColors.neutral100;
  Color get neutralMedium => AppColors.neutral300;
  Color get neutralDark => AppColors.neutral600;
  Color get neutralDarkest => AppColors.neutral900;

  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get errorColor => AppColors.error;
  Color get infoColor => AppColors.info;
}

/// Clase principal del tema profesional
class AppTheme {
  // Colores legacy para compatibilidad
  static Color get primaryColor => AppColors.primary;
  static Color get secondaryColor => AppColors.secondary;
  static Color get accentColor => AppColors.accent;
  static Color get successColor => AppColors.success;
  static Color get warningColor => AppColors.warning;
  static Color get errorColor => AppColors.error;
  static Color get infoColor => AppColors.info;

  // Tamaños de iconos legacy
  static double get iconSm => AppIconSize.sm;
  static double get iconMd => AppIconSize.md;
  static double get iconLg => AppIconSize.lg;
  static double get iconXl => AppIconSize.xl;

  /// Tema principal profesional
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',

      // Colores del tema
      colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.accent,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.accentLight,
        onTertiaryContainer: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.neutral800,
        surface: AppColors.neutral50,
        onSurface: AppColors.neutral800,
        surfaceContainerHighest: AppColors.neutral100,
        onSurfaceVariant: AppColors.neutral600,
        outline: AppColors.neutral300,
        outlineVariant: AppColors.neutral200,
        shadow: AppColors.neutral800.withOpacity(0.1),
        scrim: AppColors.neutral900.withOpacity(0.5),
        inverseSurface: AppColors.neutral800,
        onInverseSurface: AppColors.neutral50,
        inversePrimary: AppColors.primaryLight,
        surfaceTint: AppColors.primary,
      ),

      // AppBar personalizado
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: AppColors.neutral50,
        surfaceTintColor: AppColors.primary,
        foregroundColor: AppColors.neutral800,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral800,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.neutral700,
          size: AppIconSize.md,
        ),
      ),

      // Navegación inferior
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.neutral50,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral500,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        color: AppColors.neutral50,
        surfaceTintColor: AppColors.primary,
        shadowColor: AppColors.neutral800.withOpacity(0.1),
        elevation: AppElevation.level2,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.large),
        ),
        margin: AppSpacing.all(AppSpacing.sm),
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
          elevation: AppElevation.level2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.medium),
          ),
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.neutral400,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.medium),
          ),
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Botones outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.neutral400,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.medium),
          ),
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral100,
        border: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.neutral600,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.neutral500,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Typography mejorada
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.neutral900,
          letterSpacing: -1,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
          letterSpacing: -0.8,
          height: 1.25,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral900,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral700,
          letterSpacing: 0.2,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral800,
          letterSpacing: 0.2,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral700,
          letterSpacing: 0.2,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral600,
          letterSpacing: 0.3,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral700,
          letterSpacing: 0.3,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral600,
          letterSpacing: 0.4,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral500,
          letterSpacing: 0.5,
          height: 1.4,
        ),
      ),

      // Divisores
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),

      // Lista tiles
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.medium),
        ),
      ),

      // Splash y highlight colors
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),

      // Tab bar
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.neutral600,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primary, width: 3),
          ),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
