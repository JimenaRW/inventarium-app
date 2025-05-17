import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_import_csv_state.dart';

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
      await _validateFile(File(result.files.single.path!));
    }
  }

  Future<void> _validateFile(File file) async {
    state = state.copyWith(isLoading: true, selectedFile: file);

    try {
      final csvContent = await file.readAsString();
      final lines = csvContent.split(';');
      final rawLines = <List<String>>[];
      final errors = <String>[];

      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final values = line.split('\t');

        if (values.length < 14) {
          errors.add('Fila ${i + 1}: cantidad insuficiente de columnas');
          continue;
        }

        // Validaciones por índice
        if (values[1].trim().isEmpty) {
          // codigo de barras
          errors.add('Fila ${i + 1}: código de barras no puede estar vacío');
        }
        // if (values[2].trim().isEmpty) {
        //   // codigo proveedor
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[3].trim().isEmpty) {
        //   // codigo
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        if (values[4].trim().isEmpty) {
          // codigo interno
          errors.add('Fila ${i + 1}: SKU no puede estar vacía');
        }
        // if (values[5].trim().isEmpty) {
        //   // nombre
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        if (values[6].trim().isEmpty) {
          // descripcion
          errors.add('Fila ${i + 1}: descripción no puede estar vacía');
        }
        if (values[7].trim().isEmpty) {
          // stock
          errors.add('Fila ${i + 1}: stock no puede estar vacía');
        } else {
          final ivaValue = int.tryParse(values[7].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: stock debe ser un número válido (ej: 21)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: IVA no puede ser negativo');
          }
        }
        if (values[8].trim().isEmpty) { // IVA
          errors.add('Fila ${i + 1}: El campo IVA no puede estar vacío');
        } else {
          final ivaValue = double.tryParse(values[8].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: IVA debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: IVA no puede ser negativo');
          }
        }
        // if (values[9].trim().isEmpty) {
        //   // costo
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[10].trim().isEmpty) {
        //   // ganancia1
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        if (values[11].trim().isEmpty) {
          // p.publico 1
          errors.add('Fila ${i + 1}: precio1 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[11].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: precio1 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: precio1 no puede ser negativo');
          }
        }
        // if (values[12].trim().isEmpty) {
        //   // ganancia2
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        if (values[13].trim().isEmpty) {
          // p.publico 2
          errors.add('Fila ${i + 1}: precio2 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[13].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: precio2 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: precio2 no puede ser negativo');
          }
        }
        // if (values[14].trim().isEmpty) {
        //   // ganancia3
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        if (values[15].trim().isEmpty) {
          // p.publico 3
          errors.add('Fila ${i + 1}: precio3 no puede estar vacía');
        } else {
          final ivaValue = double.tryParse(values[15].trim());
          if (ivaValue == null) {
            errors.add(
              'Fila ${i + 1}: precio3 debe ser un número válido (ej: 21.00)',
            );
          } else if (ivaValue < 0) {
            errors.add('Fila ${i + 1}: precio3 no puede ser negativo');
          }
        }
        // if (values[16].trim().isEmpty) {
        //   // ganancia4
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[17].trim().isEmpty) {
        //   // p.publico 4
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        if (values[17].trim().isEmpty) {
          // categoria
          errors.add('Fila ${i + 1}: categoria no puede estar vacía');
        }
        if (values[18].trim().isEmpty) {
          // fabricante
          errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        }
        // if (values[20].trim().isEmpty) {
        //   // proveedor1
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[21].trim().isEmpty) {
        //   // proveedor2
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[22].trim().isEmpty) {
        //   // H
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[23].trim().isEmpty) {
        //   // CostoD
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[24].trim().isEmpty) {
        //   // Ganancia5
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[25].trim().isEmpty) {
        //   // p publico 5
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[26].trim().isEmpty) {
        //   // p sugerido
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[27].trim().isEmpty) {
        //   // unidad
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[28].trim().isEmpty) {
        //   // em
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[29].trim().isEmpty) {
        //   // Mo
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        // if (values[30].trim().isEmpty) {
        //   // Nro
        //   errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        // }
        if (values[31].trim().isEmpty) {
          // ubicacion
          errors.add('Fila ${i + 1}: Descripción no puede estar vacía');
        }

        // Agrega más validaciones si es necesario

        rawLines.add(values);
      }

      state = state.copyWith(
        isLoading: false,
        validationErrors: errors,
        rawArticleLines: rawLines,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        validationErrors: ['Error al leer archivo: ${e.toString()}'],
      );
    }
  }

  bool canImport() {
    return state.validationErrors.isEmpty && state.rawArticleLines != null;
  }

  Future<void> importArticles() async {
    if (!canImport()) return;

    state = state.copyWith(isLoading: true);

    try {
      final articles =
          state.rawArticleLines!.map((values) {
            return Article(
              id: values[0].trim(),
              sku: values[1].trim(),
              descripcion: values[2].trim(),
              codigoBarras: values[3].trim(),
              categoria: values[4].trim(),
              categoriaDescripcion: values[5].trim(),
              ubicacion: values[6].trim(),
              fabricante: values[7].trim(),
              stock: int.tryParse(values[8].trim()) ?? 0,
              precio1: double.tryParse(values[9].trim()) ?? 0.0,
              precio2: double.tryParse(values[10].trim()) ?? 0.0,
              precio3: double.tryParse(values[11].trim()) ?? 0.0,
              iva: double.tryParse(values[12].trim()) ?? 0.0,
              activo: values[13].trim().toLowerCase() == 'true',
            );
          }).toList();

      await _repository.insertMany(articles);

      state = state.copyWith(
        isLoading: false,
        importSuccess: true,
        potentialArticles: articles,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        validationErrors: ['Error al importar artículos: ${e.toString()}'],
      );
    }
  }
}
