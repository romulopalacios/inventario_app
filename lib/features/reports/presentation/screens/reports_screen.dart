import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/reactive_providers.dart';
import '../../../../core/theme/app_theme_professional.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/safe_navigation.dart';
import '../../../../shared/widgets/mobile_navigation.dart';
import '../../../../shared/widgets/enhanced_ui_components.dart';
import '../widgets/financial_summary_card.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Logger.debug(
      '📊 ReportsScreen initialized with date range: ${_startDate} - ${_endDate}',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger.debug('📊 Building ReportsScreen with enhanced UI components');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        SafeNavigation.safePop(
          context,
          reason: 'Reports screen back navigation',
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: EnhancedUIComponents.enhancedAppBar(
          title: 'Reportes',
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range, color: AppColors.primary),
              onPressed: () => _selectDateRange(context),
              tooltip: 'Seleccionar rango de fechas',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Date Range Indicator
            _buildDateRangeIndicator(),

            // Tab Bar
            _buildTabBar(),

            const SizedBox(height: 16),

            // Tab Content
            Expanded(child: _buildTabContent()),
          ],
        ),
        bottomNavigationBar: const MobileBottomNavigation(
          currentRoute: '/reports',
        ),
      ),
    );
  }

  Widget _buildDateRangeIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Período de análisis',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.neutral400, size: 16),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.neutral600,
        indicatorColor: AppColors.primary,
        indicator: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerHeight: 0,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(
            icon: Icon(Icons.analytics_outlined, size: 20),
            text: 'Resumen',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          Tab(
            icon: Icon(Icons.trending_up, size: 20),
            text: 'Ventas',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          Tab(
            icon: Icon(Icons.inventory_outlined, size: 20),
            text: 'Inventario',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    final financialParams = <String, DateTime?>{
      'desde': _startDate,
      'hasta': _endDate,
    };

    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSummaryTab(financialParams),
        _buildSalesTab(financialParams),
        _buildInventoryTab(financialParams),
      ],
    );
  }

  Widget _buildSummaryTab(Map<String, DateTime?> params) {
    final financialData = ref.watch(financialDataProvider(params));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Financial Summary
          financialData.when(
            data: (data) => FinancialSummaryCard(data: data),
            loading: () => EnhancedUIComponents.enhancedLoading(),
            error:
                (error, stack) => _buildErrorCard(
                  'Error en resumen financiero',
                  error.toString(),
                ),
          ),

          const SizedBox(height: 16),

          // Daily Sales Chart
          EnhancedUIComponents.enhancedCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.show_chart,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ventas Diarias',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral800,
                              ),
                            ),
                            Text(
                              'Evolución de ventas en el período',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  EnhancedUIComponents.enhancedDivider(height: 20),

                  SizedBox(
                    height: 250,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 64,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gráfico de ventas diarias',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los datos se cargarán aquí',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSalesTab(Map<String, DateTime?> params) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Sales Chart
          EnhancedUIComponents.enhancedCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Análisis de Ventas',
                    'Gráfico detallado de ventas',
                    Icons.bar_chart,
                    AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 64,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Análisis de Ventas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gráfico detallado en desarrollo',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Sales
          EnhancedUIComponents.enhancedCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Ventas por Categoría',
                    'Distribución de ventas por categorías',
                    Icons.pie_chart_outline,
                    AppColors.warning,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart,
                            size: 64,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ventas por Categoría',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Distribución por categorías en desarrollo',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(Map<String, DateTime?> params) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Top Products
          EnhancedUIComponents.enhancedCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Productos Más Vendidos',
                    'Top productos en el período',
                    Icons.star_outline,
                    AppColors.success,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.leaderboard,
                            size: 64,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Productos Más Vendidos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lista de top productos en desarrollo',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stock Alert
          EnhancedUIComponents.enhancedCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Alerta de Stock',
                    'Productos con stock bajo',
                    Icons.warning_outlined,
                    AppColors.error,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Funcionalidad en desarrollo...',
                    style: TextStyle(
                      color: AppColors.neutral600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.neutral600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String title, String error) {
    return EnhancedUIComponents.enhancedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 13, color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
