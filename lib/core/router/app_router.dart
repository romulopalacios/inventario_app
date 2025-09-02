import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/logger.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/products_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/add_edit_product_screen.dart';
import '../../features/products/presentation/screens/stock_movement_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) {
    Logger.error('🚨 Router error: ${state.error}');
    return Scaffold(
      appBar: AppBar(title: const Text('Error de Navegación')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error de navegación: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    );
  },
  routes: [
    // Auth routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Main app routes
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Products routes
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) => const ProductsListScreen(),
      routes: [
        GoRoute(
          path: '/add',
          name: 'add-product',
          builder: (context, state) => const AddEditProductScreen(),
        ),
        GoRoute(
          path: '/:productId',
          name: 'product-detail',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return ProductDetailScreen(productId: productId);
          },
          routes: [
            GoRoute(
              path: '/edit',
              name: 'edit-product',
              builder: (context, state) {
                final productId = state.pathParameters['productId']!;
                return AddEditProductScreen(productId: productId);
              },
            ),
            GoRoute(
              path: '/stock-movement',
              name: 'stock-movement',
              builder: (context, state) {
                final productId = state.pathParameters['productId']!;
                return StockMovementScreen(productId: productId);
              },
            ),
          ],
        ),
      ],
    ),

    // Reports routes
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => const ReportsScreen(),
    ),

    // Settings routes
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
