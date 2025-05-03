import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';
import 'package:inventarium/presentation/widgets/custom_form_field.dart';

class ArticleForm extends ConsumerStatefulWidget {

  const ArticleForm({super.key});

  @override
  ConsumerState<ArticleForm> createState() => _ArticleCreateState();
}

class _ArticleCreateState extends ConsumerState<ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _codigoBarrasController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _fabricanteController;
  late final TextEditingController _stockInicialController;

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController();
    _descripcionController = TextEditingController();
    _codigoBarrasController = TextEditingController();
    _categoriaController = TextEditingController();
    _ubicacionController = TextEditingController();
    _fabricanteController = TextEditingController();
    _stockInicialController = TextEditingController();
  }

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
        codigoBarras:
            _codigoBarrasController.text.isNotEmpty
                ? _codigoBarrasController.text
                : null,
        categoria: _categoriaController.text,
        ubicacion: _ubicacionController.text,
        fabricante: _fabricanteController.text,
        stock: int.tryParse(_stockInicialController.text) ?? 0,
      );

      await ref.read(articleCreateProvider.notifier).submitForm(newArticle);
      
      final state = ref.read(articleCreateProvider);
      if (state.isSuccess && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(articleCreateProvider);

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
              minLines: 3,
              
            ),
            CustomFormField(
              controller: _descripcionController,
              labelText: 'Descripción',
              hintText: 'Ingrese la descripción del artículo',
              minLines: 3,
            ),
            CustomFormField(
              controller: _codigoBarrasController,
              labelText: 'Código de Barras',
              hintText: 'Ingrese el código de barras (opcional)',
              isRequired: false,
              minLines: 3,
            ),
            CustomFormField(
              controller: _categoriaController,
              labelText: 'Categoría',
              hintText: 'Ingrese la categoría del artículo',
              minLines: 3,
            ),
            CustomFormField(
              controller: _ubicacionController,
              labelText: 'Ubicación',
              hintText: 'Ingrese la ubicación del artículo',
              minLines: 3,
            ),
            CustomFormField(
              controller: _fabricanteController,
              labelText: 'Fabricante',
              hintText: 'Ingrese el nombre del fabricante',
              minLines: 3,
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
              minLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: formState.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  formState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Guardar artículo'),
            ),
            if (formState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  formState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
