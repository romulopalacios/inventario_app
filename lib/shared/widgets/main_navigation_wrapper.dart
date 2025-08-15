import 'package:flutter/material.dart';

/// Wrapper simple para manejo de navegación back sin PopScope
class MainNavigationWrapper extends StatelessWidget {
  final Widget child;
  final String? parentRoute;

  const MainNavigationWrapper({
    super.key,
    required this.child,
    this.parentRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Simplemente devolvemos el child sin PopScope para evitar conflictos
    return child;
  }
}

/// Widget para pantallas principales
class MainScreenWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const MainScreenWrapper({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Widget para pantallas de detalle
class DetailScreenWrapper extends StatelessWidget {
  final Widget child;
  final String parentRoute;

  const DetailScreenWrapper({
    super.key,
    required this.child,
    required this.parentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
