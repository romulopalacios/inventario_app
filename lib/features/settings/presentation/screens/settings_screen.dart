import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/mobile_navigation.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: const Center(
        child: Text('Pantalla de Configuración - En desarrollo'),
      ),
      bottomNavigationBar: MobileBottomNavigation(
        currentRoute: GoRouterState.of(context).fullPath,
      ),
    );
  }
}
