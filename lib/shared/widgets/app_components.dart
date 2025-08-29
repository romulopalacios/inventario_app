import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Card principal con diseño minimalista y animaciones sutiles
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isInteractive;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.color,
    this.borderRadius,
    this.onTap,
    this.isInteractive = false,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimation.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: AppAnimation.curve),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown:
            widget.onTap != null ? (_) => _animationController.forward() : null,
        onTapUp:
            widget.onTap != null ? (_) => _animationController.reverse() : null,
        onTapCancel:
            widget.onTap != null ? () => _animationController.reverse() : null,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: AppAnimation.medium,
                curve: AppAnimation.curve,
                decoration: BoxDecoration(
                  color: widget.color ?? theme.colorScheme.neutralLightest,
                  borderRadius: widget.borderRadius ?? AppRadius.large,
                  border: Border.all(
                    color:
                        _isHovered && widget.isInteractive
                            ? theme.colorScheme.primary.withOpacity(0.3)
                            : theme.colorScheme.neutralMedium.withOpacity(0.3),
                    width: _isHovered && widget.isInteractive ? 1.5 : 0.5,
                  ),
                  boxShadow:
                      _isHovered && widget.isInteractive
                          ? AppShadow.medium
                          : AppShadow.subtle,
                ),
                child: Padding(
                  padding: widget.padding ?? AppSpacing.all(AppSpacing.lg),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Header de sección con animación de entrada
class SectionHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  State<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimation.medium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppAnimation.curve),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: AppAnimation.curve),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Padding(
                padding: AppSpacing.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Container(
                        padding: AppSpacing.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: (widget.iconColor ?? theme.colorScheme.primary)
                              .withOpacity(0.1),
                          borderRadius: AppRadius.medium,
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor ?? theme.colorScheme.primary,
                          size: AppTheme.iconMd,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.neutralDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.trailing != null) widget.trailing!,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Card para mostrar métricas con animaciones
class MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final String? trend;
  final bool? isPositive;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.trend,
    this.isPositive,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _valueAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimation.slow,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppAnimation.bounce),
    );
    _valueAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppAnimation.curve),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: AppSpacing.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cardColor.withOpacity(0.1),
                  cardColor.withOpacity(0.05),
                ],
              ),
              borderRadius: AppRadius.large,
              border: Border.all(color: cardColor.withOpacity(0.2), width: 1),
              boxShadow: AppShadow.subtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.15),
                        borderRadius: AppRadius.medium,
                      ),
                      child: Icon(
                        widget.icon,
                        color: cardColor,
                        size: AppTheme.iconMd,
                      ),
                    ),
                    const Spacer(),
                    if (widget.trend != null) ...[
                      Container(
                        padding: AppSpacing.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (widget.isPositive ?? true)
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: AppRadius.small,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (widget.isPositive ?? true)
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: AppTheme.iconSm,
                              color:
                                  (widget.isPositive ?? true)
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              widget.trend!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    (widget.isPositive ?? true)
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  widget.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.neutralDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                FadeTransition(
                  opacity: _valueAnimation,
                  child: Text(
                    widget.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cardColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (widget.subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.neutralDark.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Estado vacío minimalista
class EmptyState extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimation.medium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppAnimation.curve),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: AppAnimation.curve),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Padding(
                padding: AppSpacing.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: AppSpacing.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.neutralLight,
                        borderRadius: AppRadius.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: AppTheme.iconXl,
                        color: theme.colorScheme.neutralDark.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.neutralDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.neutralDark.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.action != null) ...[
                      SizedBox(height: AppSpacing.lg),
                      widget.action!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Badge de estado con colores consistentes
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final bool isOutlined;

  const StatusBadge({
    super.key,
    required this.text,
    this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : badgeColor.withOpacity(0.1),
        border: isOutlined ? Border.all(color: badgeColor, width: 1) : null,
        borderRadius: AppRadius.small,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Estado de carga elegante
class LoadingState extends StatefulWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _pulseController,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationController.value * 2.0 * 3.14159,
                  child: Container(
                    width: AppTheme.iconXl,
                    height: AppTheme.iconXl,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: AppRadius.circle,
                    ),
                    child: Icon(
                      Icons.autorenew,
                      color: Colors.white,
                      size: AppTheme.iconMd,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.neutralDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Estado de error elegante
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppSpacing.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: AppRadius.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: AppTheme.iconXl,
                color: AppTheme.errorColor,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.neutralDark.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
