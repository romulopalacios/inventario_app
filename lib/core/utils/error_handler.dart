import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'logger.dart';

/// Manejador global de errores para debugging profesional
class ErrorHandler {
  static bool _initialized = false;

  /// Inicializa el manejo global de errores
  static void initialize() {
    if (_initialized) return;

    // Errores de Flutter widgets
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.error(
        'Flutter Widget Error',
        tag: 'WIDGET',
        error: details.exception,
        stackTrace: details.stack,
      );

      if (kDebugMode) {
        // En desarrollo, mostrar el error completo
        FlutterError.presentError(details);
      } else {
        // En producción, log silencioso
        Logger.error('Widget error in production', error: details.exception);
      }
    };

    // Errores de Dart no capturados
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger.error(
        'Uncaught Dart Error',
        tag: 'DART',
        error: error,
        stackTrace: stack,
      );
      return true;
    };

    _initialized = true;
    Logger.success('Error Handler initialized');
  }

  /// Wrapper para capturar errores en funciones async
  static Future<T?> catchAsync<T>(
    Future<T> Function() function, {
    String? operation,
    T? fallback,
  }) async {
    try {
      Logger.debug('Starting async operation: ${operation ?? 'Unknown'}');
      final result = await function();
      Logger.success('Completed async operation: ${operation ?? 'Unknown'}');
      return result;
    } catch (error, stackTrace) {
      Logger.error(
        'Async operation failed: ${operation ?? 'Unknown'}',
        tag: 'ASYNC',
        error: error,
        stackTrace: stackTrace,
      );
      return fallback;
    }
  }

  /// Wrapper para capturar errores en funciones síncronas
  static T? catchSync<T>(
    T Function() function, {
    String? operation,
    T? fallback,
  }) {
    try {
      Logger.debug('Starting sync operation: ${operation ?? 'Unknown'}');
      final result = function();
      Logger.success('Completed sync operation: ${operation ?? 'Unknown'}');
      return result;
    } catch (error, stackTrace) {
      Logger.error(
        'Sync operation failed: ${operation ?? 'Unknown'}',
        tag: 'SYNC',
        error: error,
        stackTrace: stackTrace,
      );
      return fallback;
    }
  }

  /// Mostrar diálogo de error al usuario
  static void showErrorDialog(BuildContext context, String message) {
    if (kDebugMode) {
      Logger.warning('Showing error dialog to user: $message');
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Reportar error crítico
  static void reportCriticalError(
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    Logger.separator('CRITICAL ERROR');
    Logger.error(
      message,
      tag: 'CRITICAL',
      error: error,
      stackTrace: stackTrace,
    );
    Logger.separator();

    // En producción, aquí se podría enviar a un servicio de reporting
    // como Crashlytics, Sentry, etc.
  }

  /// Validar estado de la aplicación
  static void validateAppState(String checkpoint) {
    Logger.debug('App state validation at: $checkpoint');

    // Aquí se pueden agregar validaciones específicas
    // Por ejemplo, verificar que providers estén inicializados
  }
}
