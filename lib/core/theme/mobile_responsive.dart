import 'package:flutter/material.dart';

/// Configuración responsive para dispositivos móviles
class MobileResponsive {
  // Breakpoints para dispositivos
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  /// Determina el tipo de dispositivo basado en el ancho
  static DeviceType getDeviceType(double width) {
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Obtiene el espaciado apropiado para el dispositivo
  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(width);

    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
    }
  }

  /// Obtiene el número de columnas para un grid
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(width);

    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return 3;
      case DeviceType.desktop:
        return 4;
    }
  }

  /// Obtiene el tamaño de card apropiado
  static double getCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(width);

    switch (deviceType) {
      case DeviceType.mobile:
        return 120.0;
      case DeviceType.tablet:
        return 140.0;
      case DeviceType.desktop:
        return 160.0;
    }
  }

  /// Obtiene el espaciado entre cards
  static double getCardSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(width);

    switch (deviceType) {
      case DeviceType.mobile:
        return 12.0;
      case DeviceType.tablet:
        return 16.0;
      case DeviceType.desktop:
        return 20.0;
    }
  }

  /// Obtiene el tamaño de fuente responsivo
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(width);

    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize * 0.9;
      case DeviceType.tablet:
        return baseFontSize;
      case DeviceType.desktop:
        return baseFontSize * 1.1;
    }
  }

  /// Verifica si estamos en un dispositivo móvil
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Verifica si estamos en una tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Verifica si estamos en desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Obtiene la orientación recomendada para la pantalla
  static bool shouldUsePortraitLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height > size.width && isMobile(context);
  }
}

/// Enum para tipos de dispositivo
enum DeviceType { mobile, tablet, desktop }

/// Widget helper para responsive design
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = MobileResponsive.getDeviceType(
      MediaQuery.of(context).size.width,
    );

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Extensión para MediaQuery
extension MediaQueryExtension on BuildContext {
  /// Obtiene el tamaño de la pantalla
  Size get screenSize => MediaQuery.of(this).size;

  /// Obtiene el ancho de la pantalla
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Obtiene la altura de la pantalla
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Verifica si es móvil
  bool get isMobile => MobileResponsive.isMobile(this);

  /// Verifica si es tablet
  bool get isTablet => MobileResponsive.isTablet(this);

  /// Verifica si es desktop
  bool get isDesktop => MobileResponsive.isDesktop(this);

  /// Obtiene el tipo de dispositivo
  DeviceType get deviceType => MobileResponsive.getDeviceType(screenWidth);

  /// Obtiene padding responsive
  EdgeInsets get responsivePadding => MobileResponsive.getScreenPadding(this);

  /// Obtiene columnas de grid responsive
  int get responsiveColumns => MobileResponsive.getGridColumns(this);
}
