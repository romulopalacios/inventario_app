import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/inventory_service.dart';
import '../../../../core/services/barcode_scanner_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../shared/widgets/category_dropdown.dart';
import '../../../../shared/widgets/product_image_gallery.dart';
import '../../../../shared/widgets/mobile_navigation.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool get isEditing => widget.productId != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    if (widget.productId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final db = ref.read(databaseProvider);
      final product = await db.getProductByUuid(widget.productId!);

      if (product != null && mounted) {
        _nameController.text = product.name;
        _codeController.text = product.code ?? '';
        _selectedCategory = product.category;
        _purchasePriceController.text = product.purchasePrice.toString();
        _salePriceController.text = product.salePrice.toString();
        _stockController.text = product.stock.toString();
        _minStockController.text = product.minStock.toString();
        _descriptionController.text = product.description ?? '';

        setState(() {
          // Data loaded
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar producto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while editing product data is being loaded
    if (isEditing && _isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Agregar Producto'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Basic Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Producto *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                labelText: 'Código/SKU',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _scanBarcode,
                            icon: const Icon(Icons.qr_code_scanner),
                            tooltip: 'Escanear código',
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CategoryDropdown(
                        initialValue: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        hintText: 'Seleccionar categoría',
                        allowEmpty: true,
                        allowCreate: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pricing Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precios',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _purchasePriceController,
                              decoration: const InputDecoration(
                                labelText: 'Precio de Compra',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final price = double.tryParse(value);
                                  if (price == null || price < 0) {
                                    return 'Precio inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _salePriceController,
                              decoration: const InputDecoration(
                                labelText: 'Precio de Venta *',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Precio obligatorio';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price < 0) {
                                  return 'Precio inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Stock Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventario',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Inicial',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final stock = int.tryParse(value);
                                  if (stock == null || stock < 0) {
                                    return 'Stock inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _minStockController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Mínimo',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final minStock = int.tryParse(value);
                                  if (minStock == null || minStock < 0) {
                                    return 'Stock mínimo inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Image Gallery (solo si estamos editando y tenemos el ID)
              if (isEditing && widget.productId != null)
                ProductImageGallery(
                  productId: widget.productId!,
                  productName:
                      _nameController.text.isEmpty
                          ? 'Producto'
                          : _nameController.text,
                  allowEdit: true,
                  onImageAdded: (imagePath) {
                    // Opcionalmente, puedes manejar cuando se agrega una imagen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Imagen agregada')),
                    );
                  },
                  onImageDeleted: (imagePath) {
                    // Opcionalmente, puedes manejar cuando se elimina una imagen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Imagen eliminada')),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                            isEditing
                                ? 'Actualizar Producto'
                                : 'Guardar Producto',
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MobileBottomNavigation(
        currentRoute: GoRouterState.of(context).fullPath,
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      final scannedCode = await BarcodeScannerService.scanBarcode(context);
      if (scannedCode != null) {
        setState(() {
          _codeController.text = scannedCode;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Código escaneado: $scannedCode'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(productServiceProvider);

      if (isEditing) {
        await service.updateProduct(
          uuid: widget.productId!,
          name: _nameController.text.trim(),
          code:
              _codeController.text.trim().isEmpty
                  ? null
                  : _codeController.text.trim(),
          category: _selectedCategory,
          purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
          salePrice: double.tryParse(_salePriceController.text) ?? 0,
          stock: int.tryParse(_stockController.text) ?? 0,
          minStock: int.tryParse(_minStockController.text) ?? 0,
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
        );
      } else {
        await service.createProduct(
          name: _nameController.text.trim(),
          code:
              _codeController.text.trim().isEmpty
                  ? null
                  : _codeController.text.trim(),
          category: _selectedCategory,
          purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
          salePrice: double.tryParse(_salePriceController.text) ?? 0,
          stock: int.tryParse(_stockController.text) ?? 0,
          minStock: int.tryParse(_minStockController.text) ?? 0,
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
        );

        // Invalidate providers to refresh data
        ref.invalidate(productsProvider);
        ref.invalidate(filteredProductsProvider);
        ref.invalidate(categoriesProvider);
        if (isEditing) {
          ref.invalidate(productDetailProvider(widget.productId!));
        }
        ref.invalidate(inventoryStatsProvider);
        ref.invalidate(lowStockProductsProvider);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Producto actualizado correctamente'
                  : 'Producto creado correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
