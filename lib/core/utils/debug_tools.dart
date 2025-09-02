import 'package:flutter/foundation.dart';
import 'dart:async';
import 'logger.dart';

/// Herramientas avanzadas de debugging
class DebugTools {
  static final Map<String, DateTime> _timers = {};
  static final Map<String, List<String>> _traces = {};

  /// Iniciar un timer para medir performance
  static void startTimer(String name) {
    _timers[name] = DateTime.now();
    Logger.debug('Timer started: $name');
  }

  /// Detener timer y mostrar duración
  static Duration? stopTimer(String name) {
    final startTime = _timers.remove(name);
    if (startTime == null) {
      Logger.warning('Timer not found: $name');
      return null;
    }

    final duration = DateTime.now().difference(startTime);
    Logger.success('Timer $name: ${duration.inMilliseconds}ms');
    return duration;
  }

  /// Medir performance de una función
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    startTimer(operation);
    try {
      final result = await function();
      stopTimer(operation);
      return result;
    } catch (error) {
      stopTimer(operation);
      Logger.error(
        'Performance measurement failed for: $operation',
        error: error,
      );
      rethrow;
    }
  }

  /// Medir performance de función síncrona
  static T measureSync<T>(String operation, T Function() function) {
    startTimer(operation);
    try {
      final result = function();
      stopTimer(operation);
      return result;
    } catch (error) {
      stopTimer(operation);
      Logger.error(
        'Performance measurement failed for: $operation',
        error: error,
      );
      rethrow;
    }
  }

  /// Crear trace de ejecución
  static void startTrace(String name) {
    _traces[name] = [];
    Logger.debug('Trace started: $name');
  }

  /// Agregar punto al trace
  static void addTracePoint(String traceName, String point) {
    final trace = _traces[traceName];
    if (trace == null) {
      Logger.warning('Trace not found: $traceName');
      return;
    }
    trace.add('${DateTime.now().millisecondsSinceEpoch}: $point');
    Logger.debug('Trace point added to $traceName: $point');
  }

  /// Finalizar y mostrar trace
  static void endTrace(String name) {
    final trace = _traces.remove(name);
    if (trace == null) {
      Logger.warning('Trace not found: $name');
      return;
    }

    Logger.separator('TRACE: $name');
    for (final point in trace) {
      Logger.debug(point);
    }
    Logger.separator();
  }

  /// Inspeccionar objeto
  static void inspect(Object? obj, {String? name}) {
    final objName = name ?? obj.runtimeType.toString();
    Logger.separator('INSPECT: $objName');

    if (obj == null) {
      Logger.debug('Object is null');
    } else if (obj is Map) {
      Logger.debug('Map with ${obj.length} entries:');
      obj.forEach((key, value) {
        Logger.debug('  $key: $value (${value.runtimeType})');
      });
    } else if (obj is List) {
      Logger.debug('List with ${obj.length} items:');
      for (int i = 0; i < obj.length; i++) {
        Logger.debug('  [$i]: ${obj[i]} (${obj[i].runtimeType})');
      }
    } else {
      Logger.debug('Object: $obj');
      Logger.debug('Type: ${obj.runtimeType}');
      Logger.debug('Hash: ${obj.hashCode}');
    }

    Logger.separator();
  }

  /// Checkpoint de estado
  static void checkpoint(String name, Map<String, dynamic> state) {
    Logger.separator('CHECKPOINT: $name');
    state.forEach((key, value) {
      Logger.debug('$key: $value');
    });
    Logger.separator();
  }

  /// Validar condiciones
  static bool validate(bool condition, String message, {String? tag}) {
    if (!condition) {
      Logger.error('Validation failed: $message', tag: tag ?? 'VALIDATE');
      if (kDebugMode) {
        throw AssertionError('Debug validation failed: $message');
      }
    }
    return condition;
  }

  /// Watch de valores para debugging
  static void watch(String name, dynamic value) {
    Logger.debug('WATCH [$name]: $value (${value.runtimeType})');
  }

  /// Información del dispositivo
  static void deviceInfo() {
    Logger.separator('DEVICE INFO');
    Logger.debug('Platform: ${defaultTargetPlatform.name}');
    Logger.debug('Debug Mode: $kDebugMode');
    Logger.debug('Profile Mode: $kProfileMode');
    Logger.debug('Release Mode: $kReleaseMode');
    Logger.separator();
  }

  /// Log de memoria (aproximado)
  static void memoryInfo() {
    if (kDebugMode) {
      Logger.separator('MEMORY INFO');
      // En Flutter web o mobile no hay acceso directo a memoria
      // pero podemos mostrar información útil
      Logger.debug('Debug tools active');
      Logger.debug('Timers active: ${_timers.length}');
      Logger.debug('Traces active: ${_traces.length}');
      Logger.separator();
    }
  }
}
