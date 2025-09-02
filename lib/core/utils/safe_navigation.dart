import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'logger.dart';

/// Utility class for safe navigation operations with professional debugging
class SafeNavigation {
  /// Safely pops the current route if possible, with logging
  static bool safePop(BuildContext context, {String? reason}) {
    final logReason = reason ?? 'Navigation pop requested';
    Logger.debug('🔙 $logReason');

    // Use GoRouter's canPop method for consistency
    if (GoRouter.of(context).canPop()) {
      Logger.debug('✅ Safe to pop - executing GoRouter navigation');
      GoRouter.of(context).pop();
      return true;
    } else {
      // If we can't pop but we're not at home, navigate to home as fallback
      final currentLocation = GoRouterState.of(context).fullPath;
      if (currentLocation != '/') {
        Logger.info(
          '🏠 Cannot pop but not at home - navigating to home as fallback',
        );
        safeGo(
          context,
          '/',
          reason: 'Fallback navigation to home from $currentLocation',
        );
        return true;
      } else {
        Logger.warning('⚠️ Cannot pop from home route - staying in place');
        return false;
      }
    }
  }

  /// Safely pops the current route and returns a value if possible
  static bool safePopWithValue<T>(
    BuildContext context,
    T value, {
    String? reason,
  }) {
    final logReason = reason ?? 'Navigation pop with value requested';
    Logger.debug('🔙 $logReason - value: $value');

    // Use GoRouter's canPop method for consistency
    if (GoRouter.of(context).canPop()) {
      Logger.debug('✅ Safe to pop with value - executing GoRouter navigation');
      GoRouter.of(context).pop(value);
      return true;
    } else {
      Logger.warning(
        '⚠️ Cannot pop with value from current route - staying in place',
      );
      return false;
    }
  }

  /// Safely navigates to a route using GoRouter with error handling
  static void safeGo(BuildContext context, String location, {String? reason}) {
    final logReason = reason ?? 'Navigation to $location requested';
    Logger.debug('🎯 $logReason');

    try {
      context.go(location);
      Logger.success('✅ Successfully navigated to $location');
    } catch (e) {
      Logger.error('❌ Failed to navigate to $location: $e');
      // Fallback to home if navigation fails
      if (location != '/') {
        Logger.info('🏠 Falling back to home page');
        context.go('/');
      }
    }
  }

  /// Safely pushes a new route using GoRouter with error handling
  static void safePush(
    BuildContext context,
    String location, {
    String? reason,
  }) {
    final logReason = reason ?? 'Push navigation to $location requested';
    Logger.debug('➕ $logReason');

    try {
      context.push(location);
      Logger.success('✅ Successfully pushed to $location');
    } catch (e) {
      Logger.error('❌ Failed to push to $location: $e');
    }
  }

  /// Safely replaces the current route using GoRouter
  static void safeReplace(
    BuildContext context,
    String location, {
    String? reason,
  }) {
    final logReason = reason ?? 'Replace navigation to $location requested';
    Logger.debug('🔄 $logReason');

    try {
      context.pushReplacement(location);
      Logger.success('✅ Successfully replaced with $location');
    } catch (e) {
      Logger.error('❌ Failed to replace with $location: $e');
    }
  }

  /// Check if we can pop using GoRouter
  static bool canPop(BuildContext context) {
    return GoRouter.of(context).canPop();
  }

  /// Pop until we reach a specific route name
  static void popUntil(
    BuildContext context,
    String routeName, {
    String? reason,
  }) {
    final logReason = reason ?? 'Pop until $routeName requested';
    Logger.debug('⏪ $logReason');

    try {
      // Keep popping while we can and haven't reached the target route
      while (GoRouter.of(context).canPop()) {
        final currentLocation = GoRouterState.of(context).fullPath;
        if (currentLocation == routeName) {
          Logger.success('✅ Reached target route: $routeName');
          break;
        }
        GoRouter.of(context).pop();
      }
    } catch (e) {
      Logger.error('❌ Failed to pop until $routeName: $e');
    }
  }

  /// Handle back button press with confirmation for exit
  static Future<bool> handleBackButton(
    BuildContext context, {
    String? reason,
  }) async {
    final logReason = reason ?? 'Back button pressed';
    Logger.debug('⬅️ $logReason');

    if (GoRouter.of(context).canPop()) {
      Logger.debug('✅ Can pop - executing back navigation');
      GoRouter.of(context).pop();
      return false; // Don't exit the app
    } else {
      Logger.debug('🚪 At root route - showing exit confirmation');
      return await _showExitConfirmation(context);
    }
  }

  /// Show exit confirmation dialog
  static Future<bool> _showExitConfirmation(BuildContext context) async {
    Logger.debug('🤔 Showing exit confirmation dialog');

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Salir de la aplicación'),
                content: const Text('¿Estás seguro de que quieres salir?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Salir'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
