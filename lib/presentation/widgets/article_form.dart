import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/upc_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';
import 'package:inventarium/presentation/widgets/custom_form_field.dart';
import 'package:share_plus/share_plus.dart';

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
  Category? _selectedCategoria;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _fabricanteController;
  late final TextEditingController _stockInicialController;
  late final TextEditingController _precio1Controller;
  late final TextEditingController _precio2Controller;
  late final TextEditingController _precio3Controller;
  late final TextEditingController _ivaController;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController();
    _descripcionController = TextEditingController();
    _codigoBarrasController = TextEditingController();
    _selectedCategoria = null;
    _ubicacionController = TextEditingController();
    _fabricanteController = TextEditingController();
    _ivaController = TextEditingController();
    _stockInicialController = TextEditingController();
    _precio1Controller = TextEditingController();
    _precio2Controller = TextEditingController();
    _precio3Controller = TextEditingController();
  }

  @override
  void dispose() {
    _skuController.dispose();
    _descripcionController.dispose();
    _codigoBarrasController.dispose();
    _ubicacionController.dispose();
    _fabricanteController.dispose();
    _ivaController.dispose();
    _stockInicialController.dispose();
    _precio1Controller.dispose();
    _precio2Controller.dispose();
    _precio3Controller.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategoria != null) {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await ref
            .read(articleRepositoryProvider)
            .uploadArticleImage(_image!, _skuController.text);
      }

      final newArticle = Article(
        sku: _skuController.text,
        descripcion: _descripcionController.text,
        codigoBarras:
            _codigoBarrasController.text.isNotEmpty
                ? _codigoBarrasController.text
                : null,
        categoria:
            _selectedCategoria != null ? _selectedCategoria!.id.toString() : "",
        ubicacion: _ubicacionController.text,
        fabricante: _fabricanteController.text,
        iva: double.tryParse(_ivaController.text) ?? 0.00,
        stock: int.tryParse(_stockInicialController.text) ?? 0,
        precio1: double.tryParse(_precio1Controller.text) ?? 0.00,
        precio2: double.tryParse(_precio2Controller.text) ?? 0.00,
        precio3: double.tryParse(_precio3Controller.text) ?? 0.00,
        estado: ArticleStatus.active.name,
        imageUrl: imageUrl,
      );

      await ref.read(articleCreateProvider.notifier).submitForm(newArticle);

      final state = ref.read(articleCreateProvider);
      if (state.isSuccess && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _selectImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  void _showImagePicker() {
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

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(articleCreateProvider);
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
                            : null,
                    color: _image == null ? Colors.grey[200] : null,
                  ),
                  child:
                      _image == null
                          ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey[600],
                          )
                          : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomFormField(
              controller: _skuController,
              labelText: 'SKU',
              hintText: 'Ingrese el código SKU',
              customValidator: (value) {
                if (value == null || value.isEmpty || value.length < 3) {
                  return 'Por favor ingrese sku';
                }
                return null;
              },
              keyboardType: TextInputType.name,
            ),
            CustomFormField(
              controller: _descripcionController,
              labelText: 'Descripción',
              hintText: 'Ingrese la descripción del artículo',
              minLines: 3,
              maxLines: 100,
            ),
            CustomFormField(
              controller: _codigoBarrasController,
              labelText: 'Código de Barras',
              hintText: 'Ingrese el código de barras (opcional)',
              isRequired: false,
              suffixIcon: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  final result = await ref
                      .read(upcNotifierProvider.notifier)
                      .scanUPC(context);
                  if (result != null) {
                    _codigoBarrasController.text = result;
                  } else {
                    final error = ref.read(upcNotifierProvider).error;
                    if (error != null) {
                      // Maneja el error
                    }
                    ;
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
                  value: _selectedCategoria,
                  decoration: const InputDecoration(
                    hintText: 'Seleccione una categoría*',
                    border: OutlineInputBorder(),
                  ),
                  items: categoriasAsync.when(
                    data:
                        (categorias) =>
                            categorias.map((categoria) {
                              return DropdownMenuItem<Category>(
                                value: categoria,
                                child: Text(categoria.descripcion),
                              );
                            }).toList(),
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
              maxLines: 100,
            ),
            CustomFormField(
              controller: _fabricanteController,
              labelText: 'Fabricante',
              hintText: 'Ingrese el nombre del fabricante',
              minLines: 3,
              maxLines: 100,
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
