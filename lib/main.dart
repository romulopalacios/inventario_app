import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme_professional.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/logger.dart';
import 'core/utils/debug_tools.dart';

void main() async {
  // Inicializar debugging profesional
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar manejo de errores
  ErrorHandler.initialize();

  // Log de inicialización
  Logger.separator('APP INITIALIZATION');
  Logger.init('Starting Inventario App');
  DebugTools.deviceInfo();

  runApp(const ProviderScope(child: InventarioApp()));
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    Logger.init('Building MaterialApp');

    return MaterialApp.router(
      title: 'Inventario Fácil',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Wrapper para capturar errores de build
        return ErrorHandler.catchSync(
              () => child ?? const SizedBox(),
              operation: 'App Builder',
              fallback: const MaterialApp(
                home: Scaffold(body: Center(child: Text('Error loading app'))),
              ),
            ) ??
            const SizedBox();
      },
    );
  }
}
