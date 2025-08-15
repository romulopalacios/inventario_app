import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/inventory_service.dart';
import '../../../../core/providers/database_providers.dart';

class StockMovementScreen extends ConsumerStatefulWidget {
  final String productId;

  const StockMovementScreen({super.key, required this.productId});

  @override
  ConsumerState<StockMovementScreen> createState() =>
      _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'entrada';
  bool _isLoading = false;
  int _currentStock = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentStock();
  }

  Future<void> _loadCurrentStock() async {
    try {
      final db = ref.read(databaseProvider);
      final product = await db.getProductByUuid(widget.productId);
      if (product != null && mounted) {
        setState(() {
          _currentStock = product.stock;
        });
      }
    } catch (e) {
      // Handle error silently or show a message
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimiento de Stock'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMovement,
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
              // Stock Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        color: _currentStock <= 0 ? Colors.red : Colors.blue,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock Actual',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          Text(
                            '$_currentStock',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  _currentStock <= 0 ? Colors.red : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (_currentStock <= 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Sin Stock',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de Movimiento',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Entrada'),
                              subtitle: const Text('Agregar stock'),
                              value: 'entrada',
                              groupValue: _selectedType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Salida'),
                              subtitle: const Text('Reducir stock'),
                              value: 'salida',
                              groupValue: _selectedType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      RadioListTile<String>(
                        title: const Text('Ajuste'),
                        subtitle: const Text('Establecer cantidad exacta'),
                        value: 'ajuste',
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles del Movimiento',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText:
                              _selectedType == 'ajuste'
                                  ? 'Nueva cantidad *'
                                  : 'Cantidad *',
                          border: const OutlineInputBorder(),
                          helperText:
                              _selectedType == 'ajuste'
                                  ? 'Cantidad total que quedará en stock'
                                  : 'Cantidad a ${_selectedType == 'entrada' ? 'agregar' : 'quitar'} (Stock actual: $_currentStock)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La cantidad es obligatoria';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Ingresa una cantidad válida';
                          }

                          // Validate for salida (exit) operations
                          if (_selectedType == 'salida' &&
                              quantity > _currentStock) {
                            return 'No hay suficiente stock (actual: $_currentStock)';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Motivo',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Compra, Venta, Devolución, etc.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notas adicionales',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMovement,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _getButtonColor(),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Text(_getButtonText()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    switch (_selectedType) {
      case 'entrada':
        return Colors.green;
      case 'salida':
        return Colors.red;
      case 'ajuste':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  String _getButtonText() {
    switch (_selectedType) {
      case 'entrada':
        return 'Registrar Entrada';
      case 'salida':
        return 'Registrar Salida';
      case 'ajuste':
        return 'Ajustar Stock';
      default:
        return 'Guardar Movimiento';
    }
  }

  Future<void> _saveMovement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(productServiceProvider);

      await service.addStockMovement(
        productUuid: widget.productId,
        type: _selectedType,
        quantity: int.parse(_quantityController.text),
        reason:
            _reasonController.text.trim().isEmpty
                ? null
                : _reasonController.text.trim(),
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );

      // Invalidate providers to refresh data
      ref.invalidate(productsProvider);
      ref.invalidate(productDetailProvider(widget.productId));
      ref.invalidate(stockMovementsProvider(widget.productId));
      ref.invalidate(inventoryStatsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movimiento registrado correctamente'),
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
