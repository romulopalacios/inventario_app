import 'package:flutter/material.dart';
import '../../core/theme/app_theme_professional.dart';

/// Componentes UI mejorados para consistencia visual en toda la aplicación
class EnhancedUIComponents {
  /// Card mejorada con efectos visuales y diseño consistente
  static Widget enhancedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double elevation = 4.0,
    double borderRadius = 16.0,
    VoidCallback? onTap,
    bool showShadow = true,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isSelected ? AppColors.primaryLight : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            showShadow
                ? [
                  BoxShadow(
                    color: AppColors.neutral300.withValues(alpha: 0.3),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.neutral100.withValues(alpha: 0.8),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                    spreadRadius: -2,
                  ),
                ]
                : null,
        border:
            isSelected
                ? Border.all(color: AppColors.primary, width: 2.0)
                : Border.all(color: AppColors.neutral200, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }

  /// AppBar personalizada mejorada
  static PreferredSizeWidget enhancedAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
    Color? backgroundColor,
    bool centerTitle = true,
    double elevation = 0.0,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral800,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.neutral50,
      surfaceTintColor: Colors.transparent,
      leading:
          showBackButton && leading == null
              ? IconButton(
                onPressed: onBackPressed,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.neutral700,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
              : leading,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.neutral200.withValues(alpha: 0.3),
                AppColors.neutral300.withValues(alpha: 0.7),
                AppColors.neutral200.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Botón flotante mejorado
  static Widget enhancedFloatingButton({
    required VoidCallback onPressed,
    required IconData icon,
    String? label,
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 8.0,
    bool isExtended = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.primary).withValues(
              alpha: 0.3,
            ),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child:
          isExtended && label != null
              ? FloatingActionButton.extended(
                onPressed: onPressed,
                icon: Icon(icon, size: 24),
                label: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: backgroundColor ?? AppColors.primary,
                foregroundColor: foregroundColor ?? Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              )
              : FloatingActionButton(
                onPressed: onPressed,
                backgroundColor: backgroundColor ?? AppColors.primary,
                foregroundColor: foregroundColor ?? Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28),
              ),
    );
  }

  /// Campo de búsqueda mejorado
  static Widget enhancedSearchField({
    required TextEditingController controller,
    required String hintText,
    Function(String)? onChanged,
    VoidCallback? onClear,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool autofocus = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral300.withValues(alpha: 0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: AppColors.neutral200, width: 1.0),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: autofocus,
        style: const TextStyle(fontSize: 16, color: AppColors.neutral800),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            color: AppColors.neutral500,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon:
              prefixIcon ??
              const Icon(Icons.search, color: AppColors.neutral500, size: 24),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    onPressed:
                        onClear ??
                        () {
                          controller.clear();
                          if (onChanged != null) onChanged('');
                        },
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.neutral400,
                      size: 20,
                    ),
                  )
                  : suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// Chip de filtro mejorado
  static Widget enhancedFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? selectedColor,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.neutral600,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.neutral700,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: backgroundColor ?? Colors.white,
        selectedColor: selectedColor ?? AppColors.primary,
        checkmarkColor: Colors.white,
        elevation: isSelected ? 4 : 2,
        shadowColor:
            isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.neutral300.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isSelected
                    ? (selectedColor ?? AppColors.primary)
                    : AppColors.neutral300,
            width: 1,
          ),
        ),
      ),
    );
  }

  /// Lista vacía mejorada
  static Widget enhancedEmptyState({
    required String title,
    required String message,
    required IconData icon,
    Widget? action,
    Color? iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.neutral400).withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? AppColors.neutral400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.neutral600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 32), action],
          ],
        ),
      ),
    );
  }

  /// Loading state mejorado
  static Widget enhancedLoading({String? message, Color? color}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color ?? AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Divider mejorado
  static Widget enhancedDivider({
    double height = 1.0,
    Color? color,
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(vertical: 16),
  }) {
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color ?? AppColors.neutral300,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  /// Badge de estado mejorado
  static Widget enhancedStatusBadge({
    required String label,
    required Color color,
    IconData? icon,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
