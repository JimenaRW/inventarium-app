
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/provider.dart';
import 'package:inventarium/presentation/widgets/custom_form_field.dart';

class ArticleForm extends ConsumerStatefulWidget {
  static const String name = 'article_form_screen';
 
  const ArticleForm({super.key});

  @override
  ConsumerState<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends ConsumerState<ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _fabricanteController = TextEditingController();
  final _stockInicialController = TextEditingController();

  @override
  void dispose() {
    _skuController.dispose();
    _descripcionController.dispose();
    _codigoBarrasController.dispose();
    _categoriaController.dispose();
    _ubicacionController.dispose();
    _fabricanteController.dispose();
    _stockInicialController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newArticle = Article(
        sku: _skuController.text,
        descripcion: _descripcionController.text,
        codigoBarras: _codigoBarrasController.text.isNotEmpty 
            ? _codigoBarrasController.text 
            : null,
        categoria: _categoriaController.text,
        ubicacion: _ubicacionController.text,
        fabricante: _fabricanteController.text,
        stockInicial: int.tryParse(_stockInicialController.text) ?? 0,
      );

      await ref.read(articleFormNotifierProvider.notifier).submitForm(newArticle);
      
      final state = ref.read(articleFormNotifierProvider);
      if (state.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artículo creado exitosamente')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(articleFormNotifierProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomFormField(
              controller: _skuController,
              labelText: 'SKU',
              hintText: 'Ingrese el código SKU',
            ),
            CustomFormField(
              controller: _descripcionController,
              labelText: 'Descripción',
              hintText: 'Ingrese la descripción del artículo',
              maxLines: 3,
            ),
            CustomFormField(
              controller: _codigoBarrasController,
              labelText: 'Código de Barras',
              hintText: 'Ingrese el código de barras (opcional)',
              isRequired: false,
            ),
            CustomFormField(
              controller: _categoriaController,
              labelText: 'Categoría',
              hintText: 'Ingrese la categoría del artículo',
            ),
            CustomFormField(
              controller: _ubicacionController,
              labelText: 'Ubicación',
              hintText: 'Ingrese la ubicación del artículo',
            ),
            CustomFormField(
              controller: _fabricanteController,
              labelText: 'Fabricante',
              hintText: 'Ingrese el nombre del fabricante',
            ),
            CustomFormField(
              controller: _stockInicialController,
              labelText: 'Stock Inicial',
              hintText: 'Ingrese la cantidad inicial en stock',
              keyboardType: TextInputType.number,
              customValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el stock inicial';
                }
                if (int.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: formState.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: formState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Guardar Artículo'),
            ),
            if (formState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  formState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}