import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_import_csv_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleImportCsvNotifier extends StateNotifier<ArticleImportCsvState> {
  // ignore: unused_field
  final ArticleRepository _repository;
  // ignore: unused_field
  final CategoryRepository _repositoryCategories;

  ArticleImportCsvNotifier(this._repository, this._repositoryCategories)
    : super(const ArticleImportCsvState());

  Future<void> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      await _validateCsv(File(result.files.single.path!));
    }
  }

  Future<void> _validateCsv(File file) async {
    state = state.copyWith(isLoading: true, selectedFile: file);

    try {
      final content = await file.readAsString();
      final lines = content.split('\n');
      final List<Article> importedArticles = [];
      final List<String> errors = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final values = line.split(',');

        if (values.length != 11) {
          errors.add('Fila ${i + 1}: cantidad insuficiente de columnas.');
          continue;
        }

        if (values[0].trim().isEmpty || values[0].trim() == "0") {
          errors.add('Fila ${i + 1}: código de barras no puede estar vacío');
        }
        if (values[1].trim().isEmpty || values[1].trim() == "0") {
          errors.add('Fila ${i + 1}: SKU no puede estar vacía');
        }
        if (values[2].trim().isEmpty) {
          errors.add('Fila ${i + 1}: descripción no puede estar vacía');
        }
        if (values[3].trim().isEmpty) {
          errors.add('Fila ${i + 1}: categoría no puede estar vacía');
        }
        if (values[4].trim().isEmpty) {
          errors.add('Fila ${i + 1}: fabricante no puede estar vacía');
        }
        if (values[5].trim().isEmpty) {
          errors.add('Fila ${i + 1}: ubicación no puede estar vacía');
        }
        if (values[6].trim().isEmpty) {
          errors.add('Fila ${i + 1}: stock no puede estar vacía');
        } else {
          final ivaValue = int.tryParse(values[6].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: stock debe ser un número válido (ej: 21)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: IVA no puede ser negativo');
          }
        }
        if (values[7].trim().isEmpty) {
          errors.add('Fila ${i + 1}: precio 1 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[7].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: precio 1 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: precio 1 no puede ser negativo');
          }
        }
        if (values[8].trim().isEmpty) {
          errors.add('Fila ${i + 1}: precio 2 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[8].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: precio 2 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: precio 2 no puede ser negativo');
          }
        }
        if (values[9].trim().isEmpty) {
          errors.add('Fila ${i + 1}: precio 3 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[9].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: precio 3 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: precio 3 no puede ser negativo');
          }
        }
        if (values[10].trim().isEmpty) {
          errors.add('Fila ${i + 1}: El campo IVA no puede estar vacío');
        } else {
          final ivaValue = double.tryParse(values[10].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: IVA debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: IVA no puede ser negativo');
          }
        }
      }

      if (errors.isEmpty) {
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          final values = line.split(',');

          try {
            final potentialArticle = Article(
              id: '',
              barcode: values[0].trim(),
              sku: values[1].trim(),
              description: capitalizeFirstLetter(values[2].trim()),
              category: values[3].trim(), // descripcion futura
              fabricator: capitalizeFirstLetter(values[4].trim()),
              location: capitalizeFirstLetter(values[5].trim()),
              stock: int.tryParse(values[6].trim()) ?? 0,
              price1: double.tryParse(values[7].trim()) ?? 0.0,
              price2: double.tryParse(values[8].trim()) ?? 0.0,
              price3: double.tryParse(values[9].trim()) ?? 0.0,
              iva: double.tryParse(values[10].trim()) ?? 0.0,
            );

            importedArticles.add(potentialArticle);
          } catch (e) {
            errors.add('Fila ${i + 1}: error al interpretar los datos.');
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        validationErrors: errors,
        rawArticleLines: [],
        potentialArticles: errors.isEmpty ? importedArticles : [],
        importedCount: importedArticles.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        validationErrors: [
          ...state.validationErrors,
          'Error al leer el archivo: ${e.toString()}',
        ],
      );
    }
  }

  bool canImport() {
    return state.validationErrors.isEmpty && state.potentialArticles != null;
  }

  Future<void> importArticles() async {
    if (!canImport()) return;

    state = state.copyWith(isLoading: true);

    try {
      final firestore = FirebaseFirestore.instance;
      final articlesRef = firestore.collection('articles');
      final categoriesRef = firestore.collection('categories');

      final List<void Function(WriteBatch)> operations = [];

      final catSnapshot = await categoriesRef.get();
      final Map<String, String> currentCategories = {
        for (var doc in catSnapshot.docs)
          _normalizeCategoryName(
                (doc.data()['description'] ?? '').toString().trim(),
              ):
              doc.id,
      };

      final Set<String> importedCategories =
          state.potentialArticles!
              .map((a) => _normalizeCategoryName(a.category))
              .where((e) => e.isNotEmpty)
              .toSet();

      final Set<String> loadedCategories = currentCategories.keys.toSet();

      final categoriesToInsert = importedCategories.difference(
        loadedCategories,
      );

      final List<void Function(WriteBatch)> operationsCategories = [];

      for (final description in categoriesToInsert) {
        operationsCategories.add((batch) {
          final ref = categoriesRef.doc();
          batch.set(ref, {
            'description': _normalizeCategoryName(description.trim()),
            'id': ref.id,
            'status': CategoryStatus.active.name,
          });
        });
      }

      await _runBatch(operationsCategories);

      final reloadCatSnapshot = await categoriesRef.get();
      final Map<String, String> catDescriptionToId = {
        for (var doc in reloadCatSnapshot.docs)
          _normalizeCategoryName(
                (doc.data()['description'] ?? '').toString().trim(),
              ):
              doc.id,
      };

      final artSnapshot = await articlesRef.get();
      final Map<String, String> currentArticles = {
        for (var doc in artSnapshot.docs)
          (doc.data()['sku'] ?? '').toString(): doc.id,
      };

      final Set<String> importedArticleSku =
          state.potentialArticles!.map((a) => a.sku).toSet();
      final Set<String> loadedArticleSku = currentArticles.keys.toSet();

      final articleToInsert = importedArticleSku.difference(loadedArticleSku);
      final articleToUpdate = importedArticleSku.intersection(loadedArticleSku);

      final List<Article> toInsert = await Future.wait(
        state.potentialArticles!
            .where((a) => articleToInsert.contains(a.sku))
            .map((a) async {
              final categoryKey = _normalizeCategoryName(a.category ?? '');
              var catId = catDescriptionToId[categoryKey] ?? '';

              return a.copyWith(category: catId);
            })
            .toList(),
      );

      final List<Article> toUpdate = await Future.wait(
        state.potentialArticles!
            .where((a) => articleToUpdate.contains(a.sku))
            .map((a) async {
              final categoryKey = _normalizeCategoryName(a.category ?? '');
              var catId = catDescriptionToId[categoryKey] ?? '';

              return a.copyWith(category: catId);
            })
            .toList(),
      );

      for (final article in toInsert) {
        operations.add((batch) {
          final ref = articlesRef.doc();
          batch.set(ref, {
            ...article.toFirestore(),
            'id': ref.id,
            'status': ArticleStatus.active.name,
            'imageUrl': '',
          });
        });
      }

      final querySnapshot = await articlesRef.where('sku').get();

      for (final doc in querySnapshot.docs) {
        final article = toUpdate.firstWhere((a) => a.sku == doc['sku']);

        operations.add((batch) {
          final data = article.toFirestore();
          data.remove('imageUrl');
          data.remove('status');
          data.remove('id');
          batch.update(doc.reference, data);
        });
      }

      await _runBatch(operations);

      state = state.copyWith(isLoading: false, importSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        validationErrors: [
          ...state.validationErrors,
          'Error al importar artículos: ${e.toString()}',
        ],
      );
    }
  }

  Future<void> _runBatch(List<void Function(WriteBatch)> operaciones) async {
    const int maxBatch = 500;

    for (int i = 0; i < operaciones.length; i += maxBatch) {
      final batch = FirebaseFirestore.instance.batch();
      final grupo = operaciones.skip(i).take(maxBatch);
      for (final op in grupo) {
        op(batch);
      }
      await batch.commit();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  String capitalizeFirstLetter(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  String _normalizeCategoryName(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.trim()[0].toUpperCase() +
        input.trim().substring(1).toLowerCase();
  }

  Future<List<String>> getArticlesBySkus(
    Set<String> skusSet,
    CollectionReference<Map<String, dynamic>> articlesRef,
  ) async {
    final querySnapshot = await articlesRef.get();

    return querySnapshot.docs
        .where((doc) => skusSet.contains(doc['sku']))
        .map((article) => article.id)
        .toList();
  }
}
