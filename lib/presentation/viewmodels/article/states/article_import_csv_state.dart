import 'dart:io';

import 'package:inventarium/domain/article.dart';

class ArticleImportCsvState {
  final File? selectedFile;
  final List<Article>? potentialArticles;
  final List<String> validationErrors;
  final bool isLoading;
  final bool importSuccess;
  final int? importedCount;
  final List<List<String>>? rawArticleLines;



  bool get isValid => validationErrors.isEmpty && potentialArticles != null;

  const ArticleImportCsvState({
    this.selectedFile,
    this.potentialArticles,
    this.validationErrors = const [],
    this.isLoading = false,
    this.importSuccess = false,
    this.importedCount,
    this.rawArticleLines,
  });

  ArticleImportCsvState copyWith({
    File? selectedFile,
    List<Article>? potentialArticles,
    List<String>? validationErrors,
    bool? isLoading,
    bool? importSuccess,
    int? importedCount,
    List<List<String>>? rawArticleLines,
  }) {
    return ArticleImportCsvState(
      selectedFile: selectedFile ?? this.selectedFile,
      potentialArticles: potentialArticles ?? this.potentialArticles,
      validationErrors: validationErrors ?? this.validationErrors,
      isLoading: isLoading ?? this.isLoading,
      importSuccess: importSuccess ?? this.importSuccess,
      importedCount: importedCount ?? this.importedCount,
      rawArticleLines: rawArticleLines ?? this.rawArticleLines,
    );
  }
}