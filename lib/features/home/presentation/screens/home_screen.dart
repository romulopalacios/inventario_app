import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/app_theme_professional.dart';
import '../../../../core/theme/mobile_responsive.dart';
import '../../../../shared/widgets/gesture_navigation.dart';
import '../../../../shared/widgets/sample_data_widget.dart';
import '../../../reports/presentation/widgets/inventory_summary_card.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/debug_tools.dart';
import '../../../../core/utils/safe_navigation.dart';
import '../../../../core/widgets/debug_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Logger.init('HomeScreen initialized');
    DebugTools.startTimer('HomeScreen-build');
  }

  @override
  void dispose() {
    DebugTools.stopTimer('HomeScreen-build');
    Logger.debug('HomeScreen disposed');
    super.dispose();
  }

  void _handleGestureNavigation(GestureNavigationType type) {
    Logger.navigation('HomeScreen', 'Gesture: ${type.name}');

    switch (type) {
      case GestureNavigationType.swipeLeft:
        // Navegar a productos
        context.go('/products');
        break;
      case GestureNavigationType.swipeUp:
        // Navegar a reportes
        context.go('/reports');
        break;
      case GestureNavigationType.swipeRight:
        // Navegar hacia atrás si es posible usando navegación segura
        SafeNavigation.handleBackButton(
          context,
          reason: 'Swipe right gesture detected',
        );
        break;
      case GestureNavigationType.doubleTap:
        // Refrescar datos
        ref.invalidate(lowStockProductsProvider);
        ref.invalidate(inventoryStatsProvider);
        break;
      case GestureNavigationType.longPress:
        // Mostrar menú contextual
        _showContextMenu();
        break;
    }
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.neutral50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(context.isMobile ? 20 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.refresh, color: AppColors.primary),
                  title: Text('Refrescar datos'),
                  onTap: () {
                    Logger.debug('🔄 Refresh data requested');
                    _safeNavigatorPop();
                    ref.invalidate(lowStockProductsProvider);
                    ref.invalidate(inventoryStatsProvider);
                    Logger.success('✨ Data refreshed successfully');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: AppColors.secondary),
                  title: Text('Configuración'),
                  onTap: () {
                    Logger.debug('⚙️ Settings navigation requested');
                    _safeNavigatorPop();
                    SafeNavigation.safeGo(
                      context,
                      '/settings',
                      reason: 'Settings menu item tapped',
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Logger.debug('HomeScreen building...');

    return PopScope(
      canPop: false, // We'll handle the pop manually
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await SafeNavigation.handleBackButton(
            context,
            reason: 'Android back button pressed',
          );
        }
      },
      child: DebugOverlay(
        child: GestureNavigationWrapper(
          onGestureNavigation: _handleGestureNavigation,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final lowStockProducts = ref.watch(lowStockProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(
          context.isMobile ? 'Inventario Fácil' : 'Inventario Profesional',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
            fontSize: context.isMobile ? 18 : 20,
          ),
        ),
        backgroundColor: AppColors.neutral50,
        elevation: 0,
        centerTitle: context.isMobile,
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: Icon(Icons.settings_outlined),
            color: AppColors.neutral600,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(lowStockProductsProvider);
          ref.invalidate(inventoryStatsProvider);
        },
        child: GestureAwareListView(
          padding: context.responsivePadding,
          children: [
            // Widget de datos de ejemplo
            const SampleDataWidget(),

            SizedBox(height: context.isMobile ? AppSpacing.md : AppSpacing.lg),

            // Tarjeta de bienvenida profesional
            _buildWelcomeCard(),

            SizedBox(height: context.isMobile ? AppSpacing.md : AppSpacing.lg),

            // Resumen de inventario
            const InventorySummaryCard(),

            SizedBox(height: context.isMobile ? AppSpacing.md : AppSpacing.lg),

            // Acciones rápidas profesionales
            _buildQuickActions(),

            SizedBox(height: context.isMobile ? AppSpacing.md : AppSpacing.lg),

            // Productos con stock bajo
            _buildLowStockSection(lowStockProducts),

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: context.isMobile ? _buildMobileBottomNav() : null,
      floatingActionButton:
          context.isMobile
              ? FloatingActionButton(
                onPressed: () => context.go('/products/add'),
                backgroundColor: AppColors.primary,
                child: Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildWelcomeCard() {
    return InteractiveCard(
      onTap: () => context.go('/reports'),
      enableScaleAnimation: true,
      child: Container(
        padding: EdgeInsets.all(
          context.isMobile ? AppSpacing.md : AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: context.isMobile ? 28 : 32,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Ver Reportes Detallados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: context.isMobile ? 18 : 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Accede a análisis completos de tu inventario',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: context.isMobile ? 14 : 16,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Ir a reportes',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: context.isMobile ? 16 : 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
            fontSize: context.isMobile ? 18 : 20,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ResponsiveWidget(
          mobile: _buildMobileQuickActions(),
          tablet: _buildDesktopQuickActions(),
          desktop: _buildDesktopQuickActions(),
        ),
      ],
    );
  }

  Widget _buildMobileQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_box_outlined,
                title: 'Agregar\nProducto',
                color: AppColors.success,
                onTap: () => context.go('/products/add'),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildActionCard(
                icon: Icons.inventory_2_outlined,
                title: 'Ver\nProductos',
                color: AppColors.info,
                onTap: () => context.go('/products'),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_outlined,
                title: 'Ver\nReportes',
                color: AppColors.accent,
                onTap: () => context.go('/reports'),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildActionCard(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                color: AppColors.warning,
                onTap: () => context.go('/settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.add_box_outlined,
            title: 'Agregar Producto',
            color: AppColors.success,
            onTap: () => context.go('/products/add'),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildActionCard(
            icon: Icons.inventory_2_outlined,
            title: 'Ver Productos',
            color: AppColors.info,
            onTap: () => context.go('/products'),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildActionCard(
            icon: Icons.analytics_outlined,
            title: 'Ver Reportes',
            color: AppColors.accent,
            onTap: () => context.go('/reports'),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildActionCard(
            icon: Icons.settings_outlined,
            title: 'Configuración',
            color: AppColors.warning,
            onTap: () => context.go('/settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isMobile = context.isMobile;

    return InteractiveCard(
      onTap: onTap,
      enableScaleAnimation: true,
      child: Container(
        padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.lg),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
              child: Icon(icon, size: isMobile ? 24 : 32, color: color),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral800,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection(AsyncValue<List<dynamic>> lowStockProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos con Stock Bajo',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
            fontSize: context.isMobile ? 18 : 20,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        lowStockProducts.when(
          data: (products) {
            if (products.isEmpty) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(
                    context.isMobile ? AppSpacing.md : AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Todos los productos tienen stock suficiente',
                          style: TextStyle(color: AppColors.neutral700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: products.length > 5 ? 5 : products.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.warning.withOpacity(0.1),
                      child: Icon(Icons.warning, color: AppColors.warning),
                    ),
                    title: Text(product.toString()),
                    subtitle: Text('Stock bajo'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/products'),
                  ),
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        ),
      ],
    );
  }

  // Safe navigation helper method
  void _safeNavigatorPop() {
    SafeNavigation.safePop(context, reason: 'Modal/Dialog close requested');
  }

  Widget _buildMobileBottomNav() {
    Logger.info('📱 Building mobile bottom navigation');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        border: Border(top: BorderSide(color: AppColors.neutral200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral800.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(minHeight: 56, maxHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Inicio', true, () => context.go('/')),
              _buildNavItem(
                Icons.inventory_2_outlined,
                'Productos',
                false,
                () => context.go('/products'),
              ),
              _buildNavItem(
                Icons.analytics_outlined,
                'Reportes',
                false,
                () => context.go('/reports'),
              ),
              _buildNavItem(
                Icons.settings_outlined,
                'Ajustes',
                false,
                () => context.go('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Logger.debug('🔘 Navigation item tapped: $label');
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.primary : AppColors.neutral500,
              ),
              const SizedBox(height: 1),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? AppColors.primary : AppColors.neutral500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
