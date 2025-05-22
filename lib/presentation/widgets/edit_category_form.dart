import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  // Future<void> _submitForm() async {
  //   if (_isSubmitting || !_formKey.currentState!.validate()) return;

  //   setState(() => _isSubmitting = true);

  //   try {
  //     await ref
  //         .read(categoriesNotifierProvider.notifier)
  //         .updateCategory(
  //           widget.categoryId,
  //           _descriptionController.text.trim(),
  //         );

  //     if (!mounted) return;

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Categoría actualizada')));

  //     Navigator.of(context, rootNavigator: true).pop();
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  //   } finally {
  //     if (mounted) setState(() => _isSubmitting = false);
  //   }
  // }

  Future<void> _submitForm() async {
    // 1️⃣ Verificación inicial
    if (!mounted || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 2️⃣ Verificación pre-await
      if (!mounted) return;

      await ref
          .read(categoriesNotifierProvider.notifier)
          .updateCategory(
            widget.categoryId,
            _descriptionController.text.trim(),
          );

      // 3️⃣ Verificación post-await (CRÍTICA)
      if (!mounted) {
        debugPrint('Operación interrumpida: Widget destruido durante await');
        return;
      }

      // 4️⃣ Navegación segura
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Categoría actualizada')));
        // Navegación explícita
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
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
            onPressed: _isSubmitting ? null : _submitForm,
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
