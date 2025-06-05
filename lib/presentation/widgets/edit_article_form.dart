import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';
import 'package:inventarium/presentation/widgets/custom_form_field.dart';

class ArticleEditForm extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleEditForm({super.key, required this.articleId});

  @override
  ConsumerState<ArticleEditForm> createState() => _ArticleEditState();
}

class _ArticleEditState extends ConsumerState<ArticleEditForm> {
  final _formKey = GlobalKey<FormState>();
  Article? _article;
  late final TextEditingController _skuController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _codigoBarrasController;
  Category? _selectedCategoria;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _fabricanteController;
  late final TextEditingController _stockInicialController;
  late final TextEditingController _precio1Controller;
  late final TextEditingController _precio2Controller;
  late final TextEditingController _precio3Controller;
  late final TextEditingController _ivaController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    final article = await ref
        .read(articleRepositoryProvider)
        .getArticleById(widget.articleId);
    setState(() {
      _article = article;
      _skuController = TextEditingController(text: article?.sku);
      _descripcionController = TextEditingController(
        text: article?.description,
      );
      _codigoBarrasController = TextEditingController(
        text: article?.barcode ?? '',
      );
      _ubicacionController = TextEditingController(text: article?.location);
      _fabricanteController = TextEditingController(text: article?.fabricator);
      _stockInicialController = TextEditingController(
        text: article?.stock.toString(),
      );
      _precio1Controller = TextEditingController(
        text: article?.price1.toString(),
      );
      _precio2Controller = TextEditingController(
        text: article?.price2.toString(),
      );
      _precio3Controller = TextEditingController(
        text: article?.price3.toString(),
      );
      _ivaController = TextEditingController(text: article?.iva.toString());
    });
  }

  @override
  void dispose() {
    _skuController.dispose();
    _descripcionController.dispose();
    _codigoBarrasController.dispose();
    _ubicacionController.dispose();
    _fabricanteController.dispose();
    _stockInicialController.dispose();
    _precio1Controller.dispose();
    _precio2Controller.dispose();
    _precio3Controller.dispose();
    _ivaController.dispose();
    super.dispose();
  }

  Future<void> _showImagePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  _selectImage();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  _takePhoto();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectImage() async {
    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedCategoria != null &&
        _article != null) {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await ref
            .read(articleRepositoryProvider)
            .uploadArticleImage(_image!, _skuController.text);
      } else {
        imageUrl = _article!.imageUrl;
      }

      final updatedArticle = _article!.copyWith(
        sku: _skuController.text,
        description: _descripcionController.text,
        barcode:
            _codigoBarrasController.text.isNotEmpty
                ? _codigoBarrasController.text
                : null,
        category: _selectedCategoria!.id.toString(),
        location: _ubicacionController.text,
        fabricator: _fabricanteController.text,
        iva: double.tryParse(_ivaController.text) ?? 0.00,
        stock: int.tryParse(_stockInicialController.text) ?? 0,
        price1: double.tryParse(_precio1Controller.text) ?? 0.00,
        price2: double.tryParse(_precio2Controller.text) ?? 0.00,
        price3: double.tryParse(_precio3Controller.text) ?? 0.00,
        status: ArticleStatus.active.name,
        imageUrl: imageUrl,
      );

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
    if (_article == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final formState = ref.watch(articleUpdateProvider);
    final categoriasAsync = ref.watch(categoriesNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(1.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ficha técnica',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            GestureDetector(
              onTap: _showImagePicker,
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image:
                        _image != null
                            ? DecorationImage(
                              fit: BoxFit.contain,
                              image: FileImage(_image!),
                            )
                            : _article?.imageUrl != null &&
                                _article!.imageUrl!.isNotEmpty
                            ? DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(_article!.imageUrl!),
                            )
                            : null,
                    color:
                        _image == null &&
                                (_article?.imageUrl == null ||
                                    (_article?.imageUrl != null &&
                                        _article!.imageUrl!.isEmpty))
                            ? Colors.grey[200]
                            : null,
                  ),
                  child:
                      (_image == null &&
                              (_article?.imageUrl == null ||
                                  (_article?.imageUrl != null &&
                                      _article!.imageUrl!.isEmpty)))
                          ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey[600],
                          )
                          : null,
                ),
              ),
            ),
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
              suffixIcon: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  final result = await context.push('/barcode-scanner');
                  if (result != null) {
                    _codigoBarrasController.text = result.toString();
                  }
                },
              ),
            ),
            Material(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: DropdownButtonFormField<Category>(
                  isExpanded: true,
                  value:
                      _selectedCategoria ??
                      categoriasAsync.when(
                        data:
                            (categorias) => categorias.firstWhereOrNull(
                              (c) => c.id == _article?.category,
                            ),
                        loading: () => null,
                        error: (_, __) => null,
                      ),
                  decoration: const InputDecoration(
                    hintText: 'Seleccione una categoría*',
                    border: OutlineInputBorder(),
                  ),
                  items: categoriasAsync.when(
                    data: (categorias) {
                      if (_selectedCategoria == null) {
                        final cat = categorias.firstWhereOrNull(
                          (c) => c.id == _article?.category,
                        );
                        if (cat != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _selectedCategoria = cat;
                            });
                          });
                        }
                      }

                      return categorias.map((categoria) {
                        return DropdownMenuItem<Category>(
                          value: categoria,
                          child: Text(categoria.description),
                        );
                      }).toList();
                    },
                    loading: () => [],
                    error: (err, stack) => [],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoria = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Seleccione una categoría' : null,
                ),
              ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Datos contables',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            CustomFormField(
              controller: _ivaController,
              labelText: 'Impuesto al Valor Agregado (IVA)',
              hintText: 'Ingrese el porcentaje de IVA',
              keyboardType: TextInputType.number,
              customValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el IVA';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
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
            CustomFormField(
              controller: _precio1Controller,
              labelText: 'Precio 1',
              hintText: 'Ingrese el precio de la lista 1',
              keyboardType: TextInputType.number,
              customValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el precio';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
            ),
            CustomFormField(
              controller: _precio2Controller,
              labelText: 'Precio 2',
              hintText: 'Ingrese el precio de la lista 2',
              keyboardType: TextInputType.number,
              customValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el precio';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
            ),
            CustomFormField(
              controller: _precio3Controller,
              labelText: 'Precio 3',
              hintText: 'Ingrese el precio de la lista 3',
              keyboardType: TextInputType.number,
              customValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el precio';
                }
                if (double.tryParse(value) == null) {
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
