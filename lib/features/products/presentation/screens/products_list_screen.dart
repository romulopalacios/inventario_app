import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/reactive_providers.dart';
import '../../../../core/theme/app_theme_professional.dart';
import '../../../../shared/widgets/barcode_search_button.dart';
import '../../../../shared/widgets/mobile_navigation.dart';
import '../../../../shared/widgets/enhanced_ui_components.dart';
import '../../../../core/utils/safe_navigation.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(filteredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchResults = ref.watch(productSearchProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: EnhancedUIComponents.enhancedAppBar(
          title: 'Productos',
          actions: [
            BarcodeSearchButton(
              onCodeScanned: (code) {
                ref.read(productSearchProvider.notifier).searchProducts(code);
                _searchController.text = code;
              },
              tooltip: 'Buscar por código de barras',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Category filter
            categories.when(
              data:
                  (categoriesList) =>
                      _buildCategoryFilter(categoriesList, selectedCategory),
              loading: () => EnhancedUIComponents.enhancedLoading(),
              error: (error, stackTrace) => Container(),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: EnhancedUIComponents.enhancedSearchField(
                controller: _searchController,
                hintText: 'Buscar productos por nombre o código...',
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    ref
                        .read(productSearchProvider.notifier)
                        .searchProducts(value);
                  } else {
                    setState(() {});
                  }
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            ),

            // Products list
            Expanded(
              child:
                  _searchController.text.isNotEmpty
                      ? _buildSearchResults(searchResults)
                      : _buildProductsList(products),
            ),
          ],
        ),
        floatingActionButton: EnhancedUIComponents.enhancedFloatingButton(
          onPressed: () => context.go('/products/add'),
          icon: Icons.add,
          label: 'Agregar Producto',
          isExtended: true,
        ),
        bottomNavigationBar: MobileBottomNavigation(
          currentRoute: GoRouterState.of(context).fullPath,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(
    List<dynamic> categories,
    String? selectedCategory,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          EnhancedUIComponents.enhancedFilterChip(
            label: 'Todos',
            icon: Icons.apps,
            isSelected: selectedCategory == null,
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
            },
          ),
          ...categories
              .map(
                (category) => EnhancedUIComponents.enhancedFilterChip(
                  label: category.name,
                  icon: Icons.category_outlined,
                  isSelected: selectedCategory == category.name,
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state =
                        category.name;
                  },
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildProductsList(AsyncValue<List<dynamic>> products) {
    return products.when(
      data: (productsList) {
        if (productsList.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(productsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productsList.length,
            itemBuilder: (context, index) {
              final product = productsList[index];
              return _buildProductCard(product);
            },
          ),
        );
      },
      loading: () => EnhancedUIComponents.enhancedLoading(),
      error:
          (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error al cargar productos: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(productsProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<dynamic>> searchResults) {
    return searchResults.when(
      data: (productsList) {
        if (productsList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No se encontraron productos'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productsList.length,
          itemBuilder: (context, index) {
            final product = productsList[index];
            return _buildProductCard(product);
          },
        );
      },
      loading: () => EnhancedUIComponents.enhancedLoading(),
      error:
          (error, stackTrace) =>
              Center(child: Text('Error en la búsqueda: $error')),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final formatter = NumberFormat.currency(locale: 'es_ES', symbol: '\$');
    final isLowStock = product.stock <= product.minStock;

    return EnhancedUIComponents.enhancedCard(
      onTap: () => SafeNavigation.safeGo(context, '/products/${product.uuid}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Product Avatar/Image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        isLowStock
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FutureBuilder<List<String>>(
                    future: ref.watch(
                      productImagesProvider(product.uuid).future,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(snapshot.data!.first),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.inventory_2_outlined,
                                  color:
                                      isLowStock
                                          ? AppColors.error
                                          : AppColors.primary,
                                  size: 28,
                                ),
                          ),
                        );
                      } else {
                        return Icon(
                          Icons.inventory_2_outlined,
                          color:
                              isLowStock ? AppColors.error : AppColors.primary,
                          size: 28,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLowStock)
                            EnhancedUIComponents.enhancedStatusBadge(
                              label: 'Stock Bajo',
                              color: AppColors.error,
                              icon: Icons.warning_outlined,
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      if (product.code != null)
                        Text(
                          'Código: ${product.code}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                          ),
                        ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.inventory_outlined,
                            size: 16,
                            color: AppColors.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatter.format(product.salePrice),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Category Badge (if exists)
            if (product.category != null) ...[
              EnhancedUIComponents.enhancedDivider(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EnhancedUIComponents.enhancedEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No hay productos',
      message:
          'Agrega tu primer producto para comenzar a gestionar tu inventario.',
      action: ElevatedButton.icon(
        onPressed: () {
          SafeNavigation.safeGo(context, '/products/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Producto'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
