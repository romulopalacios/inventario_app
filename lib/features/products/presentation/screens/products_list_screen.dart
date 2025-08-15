import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/database_providers.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          categories.when(
            data:
                (categoriesList) =>
                    _buildCategoryFilter(categoriesList, selectedCategory),
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => Container(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/products/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter(
    List<dynamic> categories,
    String? selectedCategory,
  ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Todos'),
            selected: selectedCategory == null,
            onSelected: (selected) {
              if (selected) {
                ref.read(selectedCategoryProvider.notifier).state = null;
              }
            },
          ),
          const SizedBox(width: 8),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.name),
                selected: selectedCategory == category.name,
                onSelected: (selected) {
                  ref.read(selectedCategoryProvider.notifier).state =
                      selected ? category.name : null;
                },
              ),
            ),
          ),
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
      loading: () => const Center(child: CircularProgressIndicator()),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) =>
              Center(child: Text('Error en la búsqueda: $error')),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final formatter = NumberFormat.currency(locale: 'es_ES', symbol: '\$');
    final isLowStock = product.stock <= product.minStock;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isLowStock
                  ? Colors.red.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.2),
          child:
              product.imagePath != null
                  ? ClipOval(
                    child: Image.network(
                      product.imagePath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Text(
                            product.name[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isLowStock ? Colors.red : Colors.blue,
                            ),
                          ),
                    ),
                  )
                  : Text(
                    product.name[0].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLowStock ? Colors.red : Colors.blue,
                    ),
                  ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.code != null) Text('Código: ${product.code}'),
            Text('Stock: ${product.stock}'),
            Text('Precio: ${formatter.format(product.salePrice)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLowStock) Icon(Icons.warning, color: Colors.red, size: 20),
            if (product.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.category,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        onTap: () => context.go('/products/${product.uuid}'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay productos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega tu primer producto para comenzar',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/products/add'),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Producto'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Buscar Productos'),
            content: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o código...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  ref
                      .read(productSearchProvider.notifier)
                      .searchProducts(value);
                } else {
                  ref.read(productSearchProvider.notifier).clearSearch();
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(productSearchProvider.notifier).clearSearch();
                  Navigator.of(context).pop();
                },
                child: const Text('Limpiar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}
