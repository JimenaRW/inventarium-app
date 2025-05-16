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
      final lines = csvContent.split('\n');
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
          errors.add('Fila ${i + 1}: SKU no puede estar vacío');
        }
        if (values[2].trim().isEmpty) {
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
      final articles = state.rawArticleLines!.map((values) {
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
