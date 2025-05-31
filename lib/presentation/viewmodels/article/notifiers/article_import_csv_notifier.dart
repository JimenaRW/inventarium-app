import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_import_csv_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleImportCsvNotifier extends StateNotifier<ArticleImportCsvState> {
  final ArticleRepository _repository;
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
      final List<Article> articulosImportados = [];
      final List<String> errores = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final values = line.split(',');

        if (values.length != 11) {
          errores.add('Fila ${i + 1}: cantidad insuficiente de columnas.');
          continue;
        }

        if (values[0].trim().isEmpty || values[0].trim() == "0") {
          errores.add('Fila ${i + 1}: código de barras no puede estar vacío');
        }
        if (values[1].trim().isEmpty || values[1].trim() == "0") {
          errores.add('Fila ${i + 1}: SKU no puede estar vacía');
        }
        if (values[2].trim().isEmpty) {
          errores.add('Fila ${i + 1}: descripción no puede estar vacía');
        }
        if (values[3].trim().isEmpty) {
          errores.add('Fila ${i + 1}: categoría no puede estar vacía');
        }
        if (values[4].trim().isEmpty) {
          errores.add('Fila ${i + 1}: fabricante no puede estar vacía');
        }
        if (values[5].trim().isEmpty) {
          errores.add('Fila ${i + 1}: ubicación no puede estar vacía');
        }
        if (values[6].trim().isEmpty) {
          errores.add('Fila ${i + 1}: stock no puede estar vacía');
        } else {
          final ivaValue = int.tryParse(values[6].trim());
          if (ivaValue == null) {
            errores.add(
              'Fila ${i + 1}: stock debe ser un número válido (ej: 21)',
            );
          } else if (ivaValue < 0) {
            errores.add('Fila ${i + 1}: IVA no puede ser negativo');
          }
        }
        if (values[7].trim().isEmpty) {
          errores.add('Fila ${i + 1}: precio 1 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[7].trim());
          if (ivaValue == null) {
            errores.add(
              'Fila ${i + 1}: precio 1 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errores.add('Fila ${i + 1}: precio 1 no puede ser negativo');
          }
        }
        if (values[8].trim().isEmpty) {
          errores.add('Fila ${i + 1}: precio 2 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[8].trim());
          if (ivaValue == null) {
            errores.add(
              'Fila ${i + 1}: precio 2 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errores.add('Fila ${i + 1}: precio 2 no puede ser negativo');
          }
        }
        if (values[9].trim().isEmpty) {
          errores.add('Fila ${i + 1}: precio 3 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[9].trim());
          if (ivaValue == null) {
            errores.add(
              'Fila ${i + 1}: precio 3 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errores.add('Fila ${i + 1}: precio 3 no puede ser negativo');
          }
        }
        if (values[10].trim().isEmpty) {
          errores.add('Fila ${i + 1}: El campo IVA no puede estar vacío');
        } else {
          final ivaValue = double.tryParse(values[10].trim());
          if (ivaValue == null) {
            errores.add(
              'Fila ${i + 1}: IVA debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errores.add('Fila ${i + 1}: IVA no puede ser negativo');
          }
        }
      }

      if (errores.isEmpty) {
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          final values = line.split(',');

          try {
            final articulo = Article(
              id: '',
              codigoBarras: values[0].trim(),
              sku: values[1].trim(),
              descripcion: values[2].trim(),
              categoria: values[3].trim(),
              fabricante: values[4].trim(),
              ubicacion: values[5].trim(),
              stock: int.tryParse(values[6].trim()) ?? 0,
              precio1: double.tryParse(values[7].trim()) ?? 0.0,
              precio2: double.tryParse(values[8].trim()) ?? 0.0,
              precio3: double.tryParse(values[9].trim()) ?? 0.0,
              iva: double.tryParse(values[10].trim()) ?? 0.0,
              estado: ArticleStatus.active.name,
            );

            articulosImportados.add(articulo);
          } catch (e) {
            errores.add('Fila ${i + 1}: error al interpretar los datos.');
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        validationErrors: errores,
        rawArticleLines: [],
        potentialArticles: errores.isEmpty ? articulosImportados : [],
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

  Future<void> importarArticulos() async {
    if (!canImport()) return;

    state = state.copyWith(isLoading: true);

    try {
      final firestore = FirebaseFirestore.instance;
      final articlesRef = firestore.collection('articles');
      final categoriasRef = firestore.collection('categories');

      final List<void Function(WriteBatch)> operaciones = [];

      final catSnapshot = await categoriasRef.get();
      final Map<String, String> categoriasActuales = {
        for (var doc in catSnapshot.docs)
          (doc.data()['description'] ?? '').toString().trim(): doc.id,
      };

      final Set<String> catImportadas =
          state.potentialArticles!
              .map((a) => a.categoria.trim())
              .where((e) => e.isNotEmpty)
              .toSet();

      final Set<String> catExistentes = categoriasActuales.keys.toSet();

      final categoriasAInsertar = catImportadas.difference(catExistentes);
      final categoriasADesactivar = catExistentes.difference(catImportadas);

      final List<void Function(WriteBatch)> operacionesCategorias = [];

      for (final descripcion in categoriasAInsertar) {
        operacionesCategorias.add((batch) {
          final ref = categoriasRef.doc();
          batch.set(ref, {'description': descripcion, 'id': ref.id});
        });
      }

      for (final descripcion in categoriasADesactivar) {
        final id = categoriasActuales[descripcion];
        if (id != null) {
          operacionesCategorias.add((batch) {
            final docRef = categoriasRef.doc(id);
            batch.delete(docRef);
          });
        }
      }

      await _ejecutarBatch(operacionesCategorias);

      final nuevaSnapshot = await categoriasRef.get();
      final Map<String, String> catDescripcionToId = {
        for (var doc in nuevaSnapshot.docs)
          (doc.data()['description'] ?? '').toString().trim(): doc.id,
      };

      final artSnapshot = await articlesRef.get();
      final Map<String, String> articulosActuales = {
        for (var doc in artSnapshot.docs)
          (doc.data()['sku'] ?? '').toString(): doc.id,
      };

      final Set<String> skusImportados =
          state.potentialArticles!.map((a) => a.sku).toSet();
      final Set<String> skusExistentes = articulosActuales.keys.toSet();

      final skusParaInsertar = skusImportados.difference(skusExistentes);
      final skusParaActualizar = skusImportados.intersection(skusExistentes);
      final skusParaDesactivar = skusExistentes.difference(skusImportados);

      Article mapCategoriaId(Article a) {
        final catId = catDescripcionToId[a.categoria.trim()] ?? '';
        return a.copyWith(categoria: catId);
      }

      final List<Article> paraInsertar =
          state.potentialArticles!
              .where((a) => skusParaInsertar.contains(a.sku))
              .map(mapCategoriaId)
              .toList();

      final List<Article> paraActualizar =
          state.potentialArticles!
              .where((a) => skusParaActualizar.contains(a.sku))
              .map((a) {
                final id = articulosActuales[a.sku];
                return mapCategoriaId(a.copyWith(id: id));
              })
              .toList();

      for (final articulo in paraInsertar) {
        operaciones.add((batch) {
          final ref = articlesRef.doc();
          batch.set(ref, {...articulo.toFirestore(), 'id': ref.id});
        });
      }

      for (final articulo in paraActualizar) {
        final ref = articlesRef.doc(articulo.id);
        operaciones.add((batch) {
          batch.update(ref, {...articulo.toFirestore(), 'id': ref.id});
        });
      }

      for (final sku in skusParaDesactivar) {
        final id = articulosActuales[sku];
        if (id != null) {
          final ref = articlesRef.doc(id);
          operaciones.add((batch) {
            batch.update(ref, {'status': ArticleStatus.inactive.name});
          });
        }
      }

      await _ejecutarBatch(operaciones);

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

  Future<void> _ejecutarBatch(
    List<void Function(WriteBatch)> operaciones,
  ) async {
    const int maxBatch = 500;

    for (int i = 0; i < operaciones.length; i += maxBatch) {
      final batch = FirebaseFirestore.instance.batch();
      final grupo = operaciones.skip(i).take(maxBatch);
      for (final op in grupo) op(batch);
      await batch.commit();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}
