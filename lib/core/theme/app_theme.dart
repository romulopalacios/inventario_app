import 'package:flutter/material.dart';

/// Sistema de diseño sofisticado y minimalista para la aplicación
class AppTheme {
  // Paleta de colores más sofisticada y minimalista
  static const Color primaryColor = Color(0xFF1B5E20); // Verde oscuro elegante
  static const Color primaryLightColor = Color(0xFF4CAF50); // Verde medio
  static const Color primarySurfaceColor = Color(0xFFF1F8E9); // Verde muy claro

  static const Color secondaryColor = Color(
    0xFF0D47A1,
  ); // Azul profundo profesional
  static const Color secondaryLightColor = Color(0xFF1976D2); // Azul medio
  static const Color secondarySubtleColor = Color(0xFFE8F4FD); // Azul muy claro

  // Estados con colores más sutiles
  static const Color successColor = Color(0xFF388E3C); // Verde éxito
  static const Color warningColor = Color(0xFFF57C00); // Naranja cálido
  static const Color errorColor = Color(0xFFD32F2F); // Rojo elegante
  static const Color infoColor = Color(0xFF1565C0); // Azul información

  // Grises minimalistas y sofisticados
  static const Color neutralLightest = Color(0xFFFDFDFD); // Blanco cálido
  static const Color neutralLight = Color(0xFFF8F9FA); // Gris clarísimo
  static const Color neutralMedium = Color(0xFFE9ECEF); // Gris claro
  static const Color neutralDark = Color(0xFF495057); // Gris medio
  static const Color neutralDarkest = Color(0xFF212529); // Casi negro

  // Colores adicionales para la marca
  static const Color brandAccent = Color(0xFF81C784); // Verde accent
  static const Color brandSubtle = Color(0xFFE1F5FE); // Azul muy sutil

  // Sistema de sombras más sofisticado
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> mediumShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  // Espaciado con más opciones
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;
  static const double spaceXxxl = 64.0;

  // Bordes más refinados
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Tamaños de iconos mejorados
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  /// Tema principal minimalista y elegante
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter', // Fuente más moderna y legible

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      primaryContainer: primarySurfaceColor,
      secondary: secondaryColor,
      secondaryContainer: secondarySubtleColor,
      surface: neutralLightest,
      onSurface: neutralDarkest,
      surfaceContainerHighest: neutralLight,
      outline: neutralMedium,
      error: errorColor,
    ),

    // Configuración visual general
    scaffoldBackgroundColor: neutralLight,
    cardColor: neutralLightest,
    dividerColor: neutralMedium,

    // AppBar con diseño minimalista
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      backgroundColor: neutralLightest,
      foregroundColor: neutralDarkest,
      surfaceTintColor: Colors.transparent,
      shadowColor: neutralMedium.withOpacity(0.3),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: neutralDarkest,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: neutralDark, size: iconMd),
    ),

    // Cards con sombras sutiles
    cardTheme: CardTheme(
      elevation: 0,
      color: neutralLightest,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: BorderSide(color: neutralMedium.withOpacity(0.5), width: 0.5),
      ),
      margin: EdgeInsets.symmetric(vertical: spaceSm, horizontal: spaceMd),
    ),

    // Botones elevados con gradientes sutiles
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: primaryColor.withOpacity(0.3),
        padding: EdgeInsets.symmetric(
          horizontal: spaceLg,
          vertical: spaceMd + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Botones outlined más elegantes
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        backgroundColor: primarySurfaceColor.withOpacity(0.3),
        padding: EdgeInsets.symmetric(
          horizontal: spaceLg,
          vertical: spaceMd + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        side: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.5),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Text buttons minimalistas
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Input fields más elegantes
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: neutralLightest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: spaceMd,
        vertical: spaceMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: neutralMedium, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: neutralMedium.withOpacity(0.8), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: neutralDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: neutralDark.withOpacity(0.6), fontSize: 14),
    ),

    // FAB más elegante
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),

    // Navigation bar minimalista
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: neutralDark,
      backgroundColor: neutralLightest,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Tipografía refinada
    textTheme: TextTheme(
      // Display styles - para títulos principales
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: neutralDarkest,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: neutralDarkest,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: neutralDarkest,
        letterSpacing: -0.3,
        height: 1.3,
      ),

      // Headline styles - para encabezados de sección
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: neutralDarkest,
        letterSpacing: -0.2,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: neutralDarkest,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: neutralDarkest,
        letterSpacing: 0,
        height: 1.4,
      ),

      // Title styles - para títulos de cards y componentes
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: neutralDarkest,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: neutralDarkest,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: neutralDarkest,
        letterSpacing: 0.1,
        height: 1.4,
      ),

      // Body styles - para texto principal
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: neutralDarkest,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: neutralDarkest,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: neutralDark,
        letterSpacing: 0.2,
        height: 1.5,
      ),

      // Label styles - para etiquetas y texto secundario
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: neutralDark,
        letterSpacing: 0.3,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: neutralDark,
        letterSpacing: 0.3,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: neutralDark,
        letterSpacing: 0.4,
        height: 1.4,
      ),
    ),
  );

  // Duración de animaciones
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);

  // Curves de animación
  static const Curve animationCurve = Curves.easeOutCubic;
  static const Curve animationBounceCurve = Curves.elasticOut;
}

/// Extensiones de colores mejoradas
extension AppColors on ColorScheme {
  Color get success => AppTheme.successColor;
  Color get warning => AppTheme.warningColor;
  Color get info => AppTheme.infoColor;
  Color get brandAccent => AppTheme.brandAccent;
  Color get brandSubtle => AppTheme.brandSubtle;

  Color get neutralLightest => AppTheme.neutralLightest;
  Color get neutralLight => AppTheme.neutralLight;
  Color get neutralMedium => AppTheme.neutralMedium;
  Color get neutralDark => AppTheme.neutralDark;
  Color get neutralDarkest => AppTheme.neutralDarkest;
}

/// Constantes de espaciado mejoradas
class AppSpacing {
  static const double xs = AppTheme.spaceXs;
  static const double sm = AppTheme.spaceSm;
  static const double md = AppTheme.spaceMd;
  static const double lg = AppTheme.spaceLg;
  static const double xl = AppTheme.spaceXl;
  static const double xxl = AppTheme.spaceXxl;
  static const double xxxl = AppTheme.spaceXxxl;

  // Métodos helper para EdgeInsets
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets symmetric({double? horizontal, double? vertical}) =>
      EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => EdgeInsets.only(
    left: left ?? 0,
    top: top ?? 0,
    right: right ?? 0,
    bottom: bottom ?? 0,
  );
}

/// Constantes de bordes mejoradas
class AppRadius {
  static const double xs = AppTheme.radiusXs;
  static const double sm = AppTheme.radiusSm;
  static const double md = AppTheme.radiusMd;
  static const double lg = AppTheme.radiusLg;
  static const double xl = AppTheme.radiusXl;
  static const double full = AppTheme.radiusFull;

  static BorderRadius get xsmall => BorderRadius.circular(xs);
  static BorderRadius get small => BorderRadius.circular(sm);
  static BorderRadius get medium => BorderRadius.circular(md);
  static BorderRadius get large => BorderRadius.circular(lg);
  static BorderRadius get xlarge => BorderRadius.circular(xl);
  static BorderRadius get circle => BorderRadius.circular(full);
}

/// Constantes de sombras
class AppShadow {
  static const List<BoxShadow> subtle = AppTheme.subtleShadow;
  static const List<BoxShadow> medium = AppTheme.mediumShadow;

  static List<BoxShadow> custom({
    required Color color,
    required double blurRadius,
    required Offset offset,
  }) => [BoxShadow(color: color, blurRadius: blurRadius, offset: offset)];
}

/// Constantes de animación
class AppAnimation {
  static const Duration fast = AppTheme.animationFast;
  static const Duration medium = AppTheme.animationMedium;
  static const Duration slow = AppTheme.animationSlow;

  static const Curve curve = AppTheme.animationCurve;
  static const Curve bounce = AppTheme.animationBounceCurve;
}
