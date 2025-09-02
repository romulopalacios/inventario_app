import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Utilidad profesional de logging con diferentes niveles
class Logger {
  static const String _appName = 'InventarioApp';

  /// Colores para logs en consola
  static const String _reset = '\x1b[0m';
  static const String _red = '\x1b[31m';
  static const String _green = '\x1b[32m';
  static const String _yellow = '\x1b[33m';
  static const String _blue = '\x1b[34m';
  static const String _magenta = '\x1b[35m';
  static const String _cyan = '\x1b[36m';

  /// Log de información general
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final tagString = tag != null ? '[$tag]' : '';
      developer.log(
        '$_cyan[INFO]$tagString $_reset$message',
        name: _appName,
        level: 800,
      );
      print('$_cyan[INFO]$tagString $_reset$message');
    }
  }

  /// Log de errores
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final tagString = tag != null ? '[$tag]' : '';
      developer.log(
        '$_red[ERROR]$tagString $_reset$message',
        name: _appName,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
      print('$_red[ERROR]$tagString $_reset$message');
      if (error != null) print('$_red  └── Error: $error$_reset');
      if (stackTrace != null)
        print(
          '$_red  └── Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}$_reset',
        );
    }
  }

  /// Log de advertencias
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final tagString = tag != null ? '[$tag]' : '';
      developer.log(
        '$_yellow[WARNING]$tagString $_reset$message',
        name: _appName,
        level: 900,
      );
      print('$_yellow[WARNING]$tagString $_reset$message');
    }
  }

  /// Log de depuración
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final tagString = tag != null ? '[$tag]' : '';
      developer.log(
        '$_blue[DEBUG]$tagString $_reset$message',
        name: _appName,
        level: 700,
      );
      print('$_blue[DEBUG]$tagString $_reset$message');
    }
  }

  /// Log de éxito
  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      final tagString = tag != null ? '[$tag]' : '';
      developer.log(
        '$_green[SUCCESS]$tagString $_reset$message',
        name: _appName,
        level: 800,
      );
      print('$_green[SUCCESS]$tagString $_reset$message');
    }
  }

  /// Log de inicialización
  static void init(String message, {String? tag}) {
    if (kDebugMode) {
      final tagString = tag != null ? '[$tag]' : '';
      developer.log(
        '$_magenta[INIT]$tagString $_reset$message',
        name: _appName,
        level: 800,
      );
      print('$_magenta[INIT]$tagString $_reset$message');
    }
  }

  /// Log de navegación
  static void navigation(String from, String to) {
    if (kDebugMode) {
      developer.log(
        '$_cyan[NAV] $_reset$from → $to',
        name: _appName,
        level: 800,
      );
      print('$_cyan[NAV] $_reset$from → $to');
    }
  }

  /// Log de base de datos
  static void database(
    String operation, {
    String? table,
    Map<String, dynamic>? data,
  }) {
    if (kDebugMode) {
      final tableString = table != null ? ' [$table]' : '';
      final dataString = data != null ? ' Data: $data' : '';
      developer.log(
        '$_magenta[DB]$tableString $_reset$operation$dataString',
        name: _appName,
        level: 800,
      );
      print('$_magenta[DB]$tableString $_reset$operation$dataString');
    }
  }

  /// Log de red/API
  static void network(
    String method,
    String url, {
    int? statusCode,
    Object? error,
  }) {
    if (kDebugMode) {
      final statusString = statusCode != null ? ' [$statusCode]' : '';
      final errorString = error != null ? ' Error: $error' : '';
      developer.log(
        '$_cyan[NET]$statusString $_reset$method $url$errorString',
        name: _appName,
        level: 800,
      );
      print('$_cyan[NET]$statusString $_reset$method $url$errorString');
    }
  }

  /// Separador visual para logs
  static void separator([String title = '']) {
    if (kDebugMode) {
      final titleString = title.isNotEmpty ? ' $title ' : '';
      final line =
          '═══════════════════════════════════════════════════════════════';
      print('$_blue$line$_reset');
      if (title.isNotEmpty) {
        print(
          '$_blue═══════════════════════$titleString═══════════════════════$_reset',
        );
        print('$_blue$line$_reset');
      }
    }
  }
}
