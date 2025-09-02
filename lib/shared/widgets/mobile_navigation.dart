import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme_professional.dart';
import '../../core/theme/mobile_responsive.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/safe_navigation.dart';

/// Bottom Navigation Bar optimizado para móviles con detección automática de ruta
class MobileBottomNavigation extends StatelessWidget {
  final String? currentRoute;
  final VoidCallback? onBackPressed;

  const MobileBottomNavigation({
    super.key,
    this.currentRoute,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isMobile) {
      return const SizedBox.shrink(); // No mostrar en desktop/tablet
    }

    Logger.debug(
      '📱 Building MobileBottomNavigation for route: ${currentRoute ?? "unknown"}',
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        border: Border(top: BorderSide(color: AppColors.neutral200, width: 1)),
        boxShadow: AppShadow.medium,
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(minHeight: 56, maxHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Inicio',
                route: '/',
              ),
              _buildNavItem(
                context,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Productos',
                route: '/products',
              ),
              _buildNavItem(
                context,
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: 'Reportes',
                route: '/reports',
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Ajustes',
                route: '/settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    final isActive = _isRouteActive(route);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          Logger.debug('🔘 Navigation item tapped: $label -> $route');
          SafeNavigation.safeGo(
            context,
            route,
            reason: 'Bottom navigation: $label',
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
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

  bool _isRouteActive(String route) {
    if (currentRoute == null) return false;

    // Exact match for home
    if (route == '/' && currentRoute == '/') return true;

    // Prefix match for other routes
    if (route != '/' && currentRoute!.startsWith(route)) return true;

    return false;
  }
}

/// AppBar optimizado para móviles
class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const MobileAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
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
      leading:
          showBackButton && Navigator.canPop(context)
              ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.neutral700,
                  size: 20,
                ),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
              : null,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.neutral200.withOpacity(0.3),
                AppColors.neutral200,
                AppColors.neutral200.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

/// Floating Action Button optimizado para móviles
class MobileFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;

  const MobileFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isMobile) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      child: Icon(icon, size: 28),
    );
  }
}

/// Drawer lateral para navegación móvil
class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.isMobile) {
      return const SizedBox.shrink();
    }

    return Drawer(
      backgroundColor: AppColors.neutral50,
      child: SafeArea(
        child: Column(
          children: [
            // Header del drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.inventory_2,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Inventario Fácil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Gestión profesional',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.home,
                    title: 'Inicio',
                    route: '/',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Productos',
                    route: '/products',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.add_box,
                    title: 'Agregar Producto',
                    route: '/products/add',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.analytics,
                    title: 'Reportes',
                    route: '/reports',
                  ),
                  const Divider(height: 32),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Configuración',
                    route: '/settings',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help,
                    title: 'Ayuda',
                    route: '/help',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neutral600, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.neutral800,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
