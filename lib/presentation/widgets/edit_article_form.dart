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
import 'package:inventarium/presentation/viewmodels/article/notifiers/upc_notifier.dart';
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
  late final TextEditingController _descriptionController;
  late final TextEditingController _barcodeController;
  Category? _selectedCategory;
  late final TextEditingController _locationController;
  late final TextEditingController _fabricatorController;
  late final TextEditingController _stockController;
  late final TextEditingController _price1Controller;
  late final TextEditingController _price2Controller;
  late final TextEditingController _price3Controller;
  late final TextEditingController _ivaController;
  File? _imageUrl;

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
      _descriptionController = TextEditingController(
        text: article?.description,
      );
      _barcodeController = TextEditingController(text: article?.barcode ?? '');
      _locationController = TextEditingController(text: article?.location);
      _fabricatorController = TextEditingController(text: article?.fabricator);
      _stockController = TextEditingController(text: article?.stock.toString());
      _price1Controller = TextEditingController(
        text: article?.price1.toString(),
      );
      _price2Controller = TextEditingController(
        text: article?.price2.toString(),
      );
      _price3Controller = TextEditingController(
        text: article?.price3.toString(),
      );
      _ivaController = TextEditingController(text: article?.iva.toString());
    });
  }

  @override
  void dispose() {
    _skuController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _locationController.dispose();
    _fabricatorController.dispose();
    _stockController.dispose();
    _price1Controller.dispose();
    _price2Controller.dispose();
    _price3Controller.dispose();
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
        _imageUrl = File(photo.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (photo != null) {
      setState(() {
        _imageUrl = File(photo.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null &&
        _article != null) {
      String? imageUrl;
      if (_imageUrl != null) {
        imageUrl = await ref
            .read(articleRepositoryProvider)
            .uploadArticleImage(_imageUrl!, _skuController.text);
      } else {
        imageUrl = _article!.imageUrl;
      }

      final updatedArticle = _article!.copyWith(
        sku: _skuController.text,
        description: _descriptionController.text,
        barcode:
            _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
        category: _selectedCategory!.id.toString(),
        location: _locationController.text,
        fabricator: _fabricatorController.text,
        iva: double.tryParse(_ivaController.text) ?? 0.00,
        stock: int.tryParse(_stockController.text) ?? 0,
        price1: double.tryParse(_price1Controller.text) ?? 0.00,
        price2: double.tryParse(_price2Controller.text) ?? 0.00,
        price3: double.tryParse(_price3Controller.text) ?? 0.00,
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
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

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
                        _imageUrl != null
                            ? DecorationImage(
                              fit: BoxFit.contain,
                              image: FileImage(_imageUrl!),
                            )
                            : _article?.imageUrl != null &&
                                _article!.imageUrl!.isNotEmpty
                            ? DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(_article!.imageUrl!),
                            )
                            : null,
                    color:
                        _imageUrl == null &&
                                (_article?.imageUrl == null ||
                                    (_article?.imageUrl != null &&
                                        _article!.imageUrl!.isEmpty))
                            ? Colors.grey[200]
                            : null,
                  ),
                  child:
                      (_imageUrl == null &&
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
              controller: _descriptionController,
              labelText: 'Descripción',
              hintText: 'Ingrese la descripción del artículo',
              minLines: 3,
              maxLines: 200,
            ),
            CustomFormField(
              controller: _barcodeController,
              labelText: 'Código de barras',
              hintText: 'Ingrese el código de barras (opcional)',
              isRequired: false,
              suffixIcon: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  final result = await ref
                      .read(upcNotifierProvider.notifier)
                      .scanUPC(context);
                  if (result != null) {
                    _barcodeController.text = result;
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
                      _selectedCategory ??
                      categoriesAsync.when(
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
                  items: categoriesAsync.when(
                    data: (categorias) {
                      if (_selectedCategory == null) {
                        final cat = categorias.firstWhereOrNull(
                          (c) => c.id == _article?.category,
                        );
                        if (cat != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _selectedCategory = cat;
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
                      _selectedCategory = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Seleccione una categoría' : null,
                ),
              ),
            ),
            CustomFormField(
              controller: _locationController,
              labelText: 'Ubicación',
              hintText: 'Ingrese la ubicación del artículo',
              minLines: 3,
              maxLines: 200,
            ),
            CustomFormField(
              controller: _fabricatorController,
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
              labelText: 'Impuesto al valor agregado (IVA)',
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
              controller: _stockController,
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
              controller: _price1Controller,
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
              controller: _price2Controller,
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
              controller: _price3Controller,
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
