import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository_provider.dart';

class EditCategoryForm extends ConsumerStatefulWidget {
  final String categoryId;
  final String initialDescription;

  const EditCategoryForm({
    super.key,
    required this.categoryId,
    required this.initialDescription,
  });

  @override
  ConsumerState<EditCategoryForm> createState() => _EditCategoryFormState();
}

class _EditCategoryFormState extends ConsumerState<EditCategoryForm> {
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifer = ref.watch(categoriesNotifierProvider.notifier);

    Future<void> submitForm() async {
      if (!_formKey.currentState!.validate()) return;

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      setState(() => _isSubmitting = true);

      try {
        await notifer.updateCategory(
          widget.categoryId,
          _descriptionController.text.trim(),
        );

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Categoría actualizada')),
        );
        navigator.pop();
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción de la categoría',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una descripción';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () async => await submitForm(),
            child:
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }
}