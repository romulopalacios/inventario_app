import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/reactive_providers.dart';
import '../../../../core/theme/app_theme_professional.dart';
import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/gesture_navigation.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/sales_chart_widget.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/daily_sales_chart.dart';
import '../widgets/top_products_list.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  void _handleGestureNavigation(GestureNavigationType type) {
    switch (type) {
      case GestureNavigationType.swipeRight:
        Navigator.pop(context);
        break;
      case GestureNavigationType.doubleTap:
        final params = <String, DateTime?>{
          'desde': _startDate,
          'hasta': _endDate,
        };
        ref.invalidate(financialDataProvider(params));
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          // Tab changed
        });
      }
    });

    _headerAnimationController = AnimationController(
      duration: AppAnimation.medium,
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: AppAnimation.curve,
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: AppAnimation.curve,
      ),
    );

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureNavigationWrapper(
      onGestureNavigation: _handleGestureNavigation,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final financialParams = <String, DateTime?>{
      'desde': _startDate,
      'hasta': _endDate,
    };

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar minimalista y profesional
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.neutral50,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: HapticButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.neutral700,
                  elevation: 0,
                  shape: const CircleBorder(),
                ),
                child: const Icon(Icons.arrow_back_ios, size: 20),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedBuilder(
                  animation: _headerAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: SlideTransition(
                        position: _headerSlideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.accent.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: AppSpacing.all(AppSpacing.lg),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: AppSpacing.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: AppRadius.circular(
                                          AppRadius.large,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.analytics_outlined,
                                        color: AppColors.primary,
                                        size: AppIconSize.lg,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Reportes Profesionales',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.neutral800,
                                                  letterSpacing: -0.5,
                                                ),
                                          ),
                                          SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'Análisis completo de tu inventario',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.neutral600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildDateRangeButton(context),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.lg),
                                _buildPeriodDisplay(theme),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  height: 60,
                  color: AppColors.neutral50,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.neutral600,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: theme.textTheme.labelLarge,
                    tabs: const [
                      Tab(
                        text: 'Resumen',
                        icon: Icon(Icons.dashboard_outlined, size: 20),
                      ),
                      Tab(
                        text: 'Ventas',
                        icon: Icon(Icons.trending_up, size: 20),
                      ),
                      Tab(
                        text: 'Productos',
                        icon: Icon(Icons.inventory_2_outlined, size: 20),
                      ),
                      Tab(
                        text: 'Análisis',
                        icon: Icon(Icons.pie_chart_outline, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Contenido de tabs
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildResumenTab(financialParams),
                  _buildVentasTab(financialParams),
                  _buildProductosTab(financialParams),
                  _buildAnalisisTab(financialParams),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(BuildContext context) {
    return HapticButton(
      onPressed: () => _selectDateRange(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neutral50,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.medium),
          side: BorderSide(color: AppColors.neutral300, width: 1),
        ),
        shadowColor: AppColors.neutral800.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.date_range_outlined,
            size: AppIconSize.sm,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            'Período',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDisplay(ThemeData theme) {
    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100.withOpacity(0.8),
        borderRadius: AppRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.neutral300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: AppIconSize.sm,
            color: AppColors.neutral600,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.neutral700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenTab(Map<String, DateTime?> params) {
    return SingleChildScrollView(
      padding: AppSpacing.all(AppSpacing.md),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final financialData = ref.watch(financialDataProvider(params));

              return financialData.when(
                data:
                    (data) => Column(
                      children: [
                        FinancialSummaryCard(data: data),
                        SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Column(
                            children: [
                              SectionHeader(
                                title: 'Gráfico de Ventas vs Compras',
                                subtitle:
                                    'Comparativo del período seleccionado',
                                icon: Icons.bar_chart,
                                iconColor: AppColors.primary,
                              ),
                              SizedBox(
                                height: 300,
                                child: SalesChartWidget(
                                  totalVentas: data.totalVentas,
                                  totalCompras: data.totalCompras,
                                  ganancias: data.gananciasBrutas,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                loading:
                    () => const LoadingState(
                      message: 'Cargando resumen financiero...',
                    ),
                error:
                    (error, stack) => ErrorState(
                      title: 'Error al cargar datos',
                      message: error.toString(),
                      onRetry: () => ref.refresh(financialDataProvider(params)),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVentasTab(Map<String, DateTime?> params) {
    return SingleChildScrollView(
      padding: AppSpacing.all(AppSpacing.md),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final dailySalesData = ref.watch(dailySalesProvider(params));

              return dailySalesData.when(
                data:
                    (ventasDiarias) => AppCard(
                      child: Column(
                        children: [
                          SectionHeader(
                            title: 'Tendencia de Ventas Diarias',
                            subtitle: 'Evolución de las ventas en el tiempo',
                            icon: Icons.show_chart,
                            iconColor: AppColors.accent,
                          ),
                          SizedBox(
                            height: 300,
                            child: DailySalesChart(
                              ventasDiarias: ventasDiarias,
                            ),
                          ),
                        ],
                      ),
                    ),
                loading:
                    () => const LoadingState(
                      message: 'Cargando datos de ventas...',
                    ),
                error:
                    (error, stack) => ErrorState(
                      title: 'Error en datos de ventas',
                      message: error.toString(),
                      onRetry: () => ref.refresh(dailySalesProvider(params)),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductosTab(Map<String, DateTime?> params) {
    return SingleChildScrollView(
      padding: AppSpacing.all(AppSpacing.md),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final topProductsData = ref.watch(topProductsProvider(params));

              return topProductsData.when(
                data: (productos) => TopProductsList(productos: productos),
                loading:
                    () => const LoadingState(
                      message: 'Cargando productos más vendidos...',
                    ),
                error:
                    (error, stack) => ErrorState(
                      title: 'Error en productos',
                      message: error.toString(),
                      onRetry: () => ref.refresh(topProductsProvider(params)),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalisisTab(Map<String, DateTime?> params) {
    return SingleChildScrollView(
      padding: AppSpacing.all(AppSpacing.md),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final categoryData = ref.watch(categorySalesProvider(params));

              return categoryData.when(
                data:
                    (ventasPorCategoria) => AppCard(
                      child: Column(
                        children: [
                          SectionHeader(
                            title: 'Ventas por Categoría',
                            subtitle: 'Distribución de ventas por categorías',
                            icon: Icons.pie_chart_outline,
                            iconColor: AppColors.warning,
                          ),
                          SizedBox(
                            height: 300,
                            child: CategoryPieChart(
                              ventasPorCategoria: ventasPorCategoria,
                            ),
                          ),
                        ],
                      ),
                    ),
                loading:
                    () => const LoadingState(
                      message: 'Cargando análisis por categorías...',
                    ),
                error:
                    (error, stack) => ErrorState(
                      title: 'Error en análisis',
                      message: error.toString(),
                      onRetry: () => ref.refresh(categorySalesProvider(params)),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}
