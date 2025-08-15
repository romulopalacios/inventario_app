import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/category_service.dart';

/// Widget dropdown para selección y creación de categorías
class CategoryDropdown extends ConsumerStatefulWidget {
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final String? hintText;
  final bool allowEmpty;
  final bool allowCreate;

  const CategoryDropdown({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.hintText = 'Seleccionar categoría',
    this.allowEmpty = true,
    this.allowCreate = true,
  });

  @override
  ConsumerState<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends ConsumerState<CategoryDropdown> {
  String? _selectedValue;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryNamesAsync = ref.watch(categoryNamesProvider);

    return categoryNamesAsync.when(
      data: (categoryNames) => _buildDropdown(categoryNames),
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }

  Widget _buildDropdown(List<String> categoryNames) {
    // Crear lista de items para el dropdown
    final items = <DropdownMenuItem<String>>[];

    // Agregar opción vacía si se permite
    if (widget.allowEmpty) {
      items.add(
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Sin categoría'),
        ),
      );
    }

    // Eliminar duplicados y agregar categorías existentes
    final uniqueCategories = categoryNames.toSet().toList()..sort();
    for (final category in uniqueCategories) {
      items.add(
        DropdownMenuItem<String>(value: category, child: Text(category)),
      );
    }

    // Agregar opción para crear nueva categoría si se permite
    if (widget.allowCreate) {
      items.add(
        const DropdownMenuItem<String>(
          value: '__CREATE_NEW__',
          child: Row(
            children: [
              Icon(Icons.add, size: 16),
              SizedBox(width: 8),
              Text('Crear nueva categoría...'),
            ],
          ),
        ),
      );
    }

    // Validar que el valor seleccionado existe en los items
    String? validSelectedValue = _selectedValue;
    if (_selectedValue != null &&
        !uniqueCategories.contains(_selectedValue) &&
        _selectedValue != '__CREATE_NEW__') {
      validSelectedValue = null;
    }

    return DropdownButtonFormField<String>(
      value: validSelectedValue,
      hint: Text(widget.hintText ?? 'Seleccionar categoría'),
      items: items,
      onChanged: (value) {
        if (value == '__CREATE_NEW__') {
          _showCreateCategoryDialog();
        } else {
          setState(() {
            _selectedValue = value;
          });
          widget.onChanged(value);
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nueva Categoría'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ingresa el nombre de la nueva categoría:'),
                const SizedBox(height: 16),
                TextField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la categoría',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _newCategoryController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => _createNewCategory(),
                child: const Text('Crear'),
              ),
            ],
          ),
    );
  }

  Future<void> _createNewCategory() async {
    final categoryName = _newCategoryController.text.trim();

    if (categoryName.isEmpty) {
      _showErrorSnackBar('El nombre de la categoría no puede estar vacío');
      return;
    }

    try {
      // Crear o obtener la categoría
      await ref.read(createCategoryProvider(categoryName).future);

      // Invalidar el provider para refrescar la lista
      ref.invalidate(categoryNamesProvider);

      // Seleccionar la nueva categoría
      setState(() {
        _selectedValue = categoryName;
      });
      widget.onChanged(categoryName);

      // Limpiar y cerrar diálogo
      _newCategoryController.clear();
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('Categoría "$categoryName" creada exitosamente');
      }
    } catch (e) {
      _showErrorSnackBar('Error al crear categoría: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}

/// Widget simplificado para mostrar categorías en chips
class CategoryChip extends StatelessWidget {
  final String category;
  final VoidCallback? onDeleted;
  final bool showDelete;

  const CategoryChip({
    super.key,
    required this.category,
    this.onDeleted,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(category),
      deleteIcon: showDelete ? const Icon(Icons.close, size: 16) : null,
      onDeleted: showDelete ? onDeleted : null,
      backgroundColor: Colors.blue.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }
}

/// Widget para gestionar categorías (admin)
class CategoryManagerDialog extends ConsumerWidget {
  const CategoryManagerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryStatsAsync = ref.watch(categoryStatsProvider);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Gestionar Categorías',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categoriesAsync.when(
                data:
                    (categories) => categoryStatsAsync.when(
                      data:
                          (stats) => _buildCategoryList(
                            context,
                            ref,
                            categories,
                            stats,
                          ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error: $error'),
                    ),
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text('Error: $error'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> categories,
    Map<String, int> stats,
  ) {
    if (categories.isEmpty) {
      return const Center(child: Text('No hay categorías registradas'));
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final productCount = stats[category.name] ?? 0;

        return ListTile(
          title: Text(category.name),
          subtitle: Text('$productCount productos'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed:
                productCount == 0
                    ? () => _deleteCategory(context, ref, category)
                    : null,
          ),
        );
      },
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    dynamic category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Categoría'),
            content: Text('¿Eliminar la categoría "${category.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ref.read(categoryServiceProvider).deleteCategory(category.uuid);
        ref.invalidate(categoriesProvider);
        ref.invalidate(categoryNamesProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
