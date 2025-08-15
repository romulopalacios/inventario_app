import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/inventory_service.dart';

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
                                  : 'Cantidad a ${_selectedType == 'entrada' ? 'agregar' : 'quitar'}',
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

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento registrado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
