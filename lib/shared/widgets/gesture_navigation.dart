import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tipo de navegación por gestos disponibles
enum GestureNavigationType {
  swipeRight, // Navegar hacia atrás
  swipeLeft, // Navegar a productos
  swipeUp, // Navegar a reportes
  doubleTap, // Refrescar datos
  longPress, // Acciones adicionales
}

/// Callback para manejar gestos de navegación
typedef GestureNavigationCallback = void Function(GestureNavigationType type);

/// Wrapper que proporciona navegación por gestos a cualquier pantalla
class GestureNavigationWrapper extends StatefulWidget {
  final Widget child;
  final GestureNavigationCallback? onGestureNavigation;
  final bool enableSwipeNavigation;
  final bool enableHapticFeedback;
  final double swipeThreshold;
  final Duration animationDuration;

  const GestureNavigationWrapper({
    super.key,
    required this.child,
    this.onGestureNavigation,
    this.enableSwipeNavigation = true,
    this.enableHapticFeedback = true,
    this.swipeThreshold = 100.0,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<GestureNavigationWrapper> createState() =>
      _GestureNavigationWrapperState();
}

class _GestureNavigationWrapperState extends State<GestureNavigationWrapper>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleSwipe(DragEndDetails details) {
    if (!widget.enableSwipeNavigation || _isNavigating) return;

    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx;
    final dy = velocity.dy;

    // Determinar dirección del swipe basado en la velocidad
    if (dx.abs() > dy.abs()) {
      // Swipe horizontal
      if (dx > widget.swipeThreshold) {
        _triggerGesture(GestureNavigationType.swipeRight);
      } else if (dx < -widget.swipeThreshold) {
        _triggerGesture(GestureNavigationType.swipeLeft);
      }
    } else {
      // Swipe vertical
      if (dy < -widget.swipeThreshold) {
        _triggerGesture(GestureNavigationType.swipeUp);
      }
    }
  }

  void _handleDoubleTap() {
    if (_isNavigating) return;
    _triggerGesture(GestureNavigationType.doubleTap);
  }

  void _handleLongPress() {
    if (_isNavigating) return;
    _triggerGesture(GestureNavigationType.longPress);
  }

  void _triggerGesture(GestureNavigationType type) {
    if (widget.enableHapticFeedback) {
      switch (type) {
        case GestureNavigationType.swipeRight:
        case GestureNavigationType.swipeLeft:
        case GestureNavigationType.swipeUp:
          HapticFeedback.lightImpact();
          break;
        case GestureNavigationType.doubleTap:
          HapticFeedback.mediumImpact();
          break;
        case GestureNavigationType.longPress:
          HapticFeedback.heavyImpact();
          break;
      }
    }

    setState(() => _isNavigating = true);

    _slideController.forward().then((_) {
      _slideController.reverse().then((_) {
        if (mounted) {
          setState(() => _isNavigating = false);
        }
      });
    });

    widget.onGestureNavigation?.call(type);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onPanEnd: _handleSwipe,
        onDoubleTap: _handleDoubleTap,
        onLongPress: _handleLongPress,
        child: widget.child,
      ),
    );
  }
}

/// Mixin para agregar funcionalidad de navegación por gestos
mixin GestureNavigationMixin<T extends StatefulWidget> on State<T> {
  void handleGestureNavigation(
    BuildContext context,
    GestureNavigationType type,
  ) {
    switch (type) {
      case GestureNavigationType.swipeRight:
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        break;
      case GestureNavigationType.swipeLeft:
        // Navigator.pushNamed(context, '/products');
        break;
      case GestureNavigationType.swipeUp:
        // Navigator.pushNamed(context, '/reports');
        break;
      case GestureNavigationType.doubleTap:
        // Implementar lógica de refresh
        _refreshData();
        break;
      case GestureNavigationType.longPress:
        // Mostrar menú contextual o acciones adicionales
        _showContextMenu(context);
        break;
    }
  }

  void _refreshData() {
    // Override this method in the implementing widget
  }

  void _showContextMenu(BuildContext context) {
    // Override this method in the implementing widget
  }
}

/// Botón con feedback háptico mejorado
class HapticButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool enableHapticFeedback;
  final HapticFeedback? feedbackType;

  const HapticButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.enableHapticFeedback = true,
    this.feedbackType,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed:
          onPressed != null
              ? () {
                if (enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onPressed!();
              }
              : null,
      child: child,
    );
  }
}

/// Card interactiva con animaciones y feedback háptico
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;
  final ShapeBorder? shape;
  final bool enableScaleAnimation;
  final bool enableHapticFeedback;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.padding,
    this.color,
    this.elevation = 4.0,
    this.shape,
    this.enableScaleAnimation = true,
    this.enableHapticFeedback = true,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableScaleAnimation) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableScaleAnimation) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableScaleAnimation) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      margin: widget.margin,
      color: widget.color,
      elevation: widget.elevation,
      shape: widget.shape,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(16.0),
        child: widget.child,
      ),
    );

    if (widget.enableScaleAnimation) {
      card = AnimatedBuilder(
        animation: _scaleAnimation,
        child: card,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
      );
    }

    return GestureDetector(
      onTapDown: widget.enableScaleAnimation ? _onTapDown : null,
      onTapUp: widget.enableScaleAnimation ? _onTapUp : null,
      onTapCancel: widget.enableScaleAnimation ? _onTapCancel : null,
      onTap:
          widget.onTap != null
              ? () {
                if (widget.enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                widget.onTap!();
              }
              : null,
      onLongPress:
          widget.onLongPress != null
              ? () {
                if (widget.enableHapticFeedback) {
                  HapticFeedback.mediumImpact();
                }
                widget.onLongPress!();
              }
              : null,
      child: card,
    );
  }
}

/// ListView con gestos mejorados y scroll con momentum
class GestureAwareListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool enableMomentumScrolling;
  final ScrollPhysics? physics;

  const GestureAwareListView({
    super.key,
    required this.children,
    this.padding,
    this.controller,
    this.enableMomentumScrolling = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: padding,
      physics:
          physics ??
          (enableMomentumScrolling
              ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              )
              : null),
      children: children,
    );
  }
}

/// Page route con animaciones de gestos
class GestureAwarePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset slideDirection;

  GestureAwarePageRoute({
    required this.page,
    this.slideDirection = const Offset(1.0, 0.0),
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return SlideTransition(
             position: Tween<Offset>(
               begin: slideDirection,
               end: Offset.zero,
             ).animate(
               CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
             ),
             child: child,
           );
         },
         transitionDuration: const Duration(milliseconds: 300),
       );
}
