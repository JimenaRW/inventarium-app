import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/domain/category.dart';

class EditCategoryForm extends ConsumerStatefulWidget {
  final String categoryId;
  final String initialDescription;
  final String initialStatus;

  const EditCategoryForm({
    super.key,
    required this.categoryId,
    required this.initialDescription,
    required this.initialStatus,
  });

  @override
  ConsumerState<EditCategoryForm> createState() => _EditCategoryFormState();
}

class _EditCategoryFormState extends ConsumerState<EditCategoryForm> {
  late final TextEditingController _descriptionController;
  late CategoryStatus _selectedStatus;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _selectedStatus = CategoryStatus.values.firstWhere(
      (e) => e.name == widget.initialStatus,
      orElse: () => CategoryStatus.active,
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
          _selectedStatus.name,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estado:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Radio<CategoryStatus>(
                    value: CategoryStatus.active,
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                  const Text('Activo'),
                  Radio<CategoryStatus>(
                    value: CategoryStatus.inactive,
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                  const Text('Inactivo'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () async => await submitForm(),
            child:
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
