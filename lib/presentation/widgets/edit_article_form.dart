import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_update_state.dart';
import 'package:inventarium/presentation/widgets/custom_form_field.dart';

class ArticleEditForm extends ConsumerStatefulWidget {
  final Article article;

  const ArticleEditForm({super.key, required this.article});

  @override
  ConsumerState<ArticleEditForm> createState() => _ArticleEditState();
}

class _ArticleEditState extends ConsumerState<ArticleEditForm> {
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
    _skuController = TextEditingController(text: widget.article.sku);
    _descripcionController = TextEditingController(
      text: widget.article.descripcion,
    );
    _codigoBarrasController = TextEditingController(
      text: widget.article.codigoBarras ?? '',
    );
    _categoriaController = TextEditingController(
      text: widget.article.categoria,
    );
    _ubicacionController = TextEditingController(
      text: widget.article.ubicacion,
    );
    _fabricanteController = TextEditingController(
      text: widget.article.fabricante,
    );
    _stockInicialController = TextEditingController(
      text: widget.article.stock.toString(),
    );
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
      final updatedArticle = widget.article.copyWith(
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

      // Aquí necesitarás un provider para actualizar el artículo
      // Supongo que tienes algo como articleUpdateProvider
      await ref
          .read(articleUpdateProvider.notifier)
          .updateArticle(updatedArticle);

      final state = ref.read(articleUpdateProvider);
      if (state.isSuccess && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(articleUpdateProvider);

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
              maxLines: 200,
            ),
            CustomFormField(
              controller: _descripcionController,
              labelText: 'Descripción',
              hintText: 'Ingrese la descripción del artículo',
              minLines: 3,
              maxLines: 200,
            ),
            CustomFormField(
              controller: _codigoBarrasController,
              labelText: 'Código de Barras',
              hintText: 'Ingrese el código de barras (opcional)',
              isRequired: false,
              minLines: 3,
              maxLines: 200,
            ),
            CustomFormField(
              controller: _categoriaController,
              labelText: 'Categoría',
              hintText: 'Ingrese la categoría del artículo',
              minLines: 3,
              maxLines: 200,
            ),
            CustomFormField(
              controller: _ubicacionController,
              labelText: 'Ubicación',
              hintText: 'Ingrese la ubicación del artículo',
              minLines: 3,
              maxLines: 200,
            ),
            CustomFormField(
              controller: _fabricanteController,
              labelText: 'Fabricante',
              hintText: 'Ingrese el nombre del fabricante',
              minLines: 3,
              maxLines: 200,
            ),
            CustomFormField(
              controller: _stockInicialController,
              labelText: 'Stock',
              hintText: 'Ingrese la cantidad en stock',
              keyboardType: TextInputType.number,
              customValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el stock';
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
              child:
                  formState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Guardar cambios'),
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
