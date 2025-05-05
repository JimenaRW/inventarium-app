import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository_provider.dart';

class CategoryForm extends ConsumerStatefulWidget {
  const CategoryForm({super.key});

  @override
  ConsumerState<CategoryForm> createState() => _CategoryCreateState();
}

class _CategoryCreateState extends ConsumerState<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(categoriesNotifierProvider.notifier)
          .addCategory(_categoryNameController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría añadida correctamente')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
              hintText: 'Tipo de categoría',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un nombre para la categoría';
              }
              return null;
            },
            autofocus: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child:
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Categoría'),
          ),
        ],
      ),
    );
  }
}
