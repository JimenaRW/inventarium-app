import 'package:collection/collection.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/i_article_repository.dart';

class ArticleRepository implements IArticleRepository {
  final List<Article> _articles = [
    Article(
      sku: '123456',
      descripcion: 'Articulo 1',
      codigoBarras: '1234567890123',
      categoria: 'Categoria 1',
      ubicacion: 'Ubicacion 1',
      fabricante: 'Fabricante 1',
      stockInicial: 10,
      precio1: 100.0,
      precio2: 200.0,
      precio3: 300.0,
      iva: 21,
    ),
    Article(
      sku: '234567',
      descripcion: 'Articulo 2',
      codigoBarras: '2345678901234',
      categoria: 'Categoria 2',
      ubicacion: 'Ubicacion 2',
      fabricante: 'Fabricante 2',
      stockInicial: 20,
      precio1: 150.0,
      precio2: 250.0,
      precio3: 350.0,
      iva: 21,
    ),
    Article(
      sku: '345678',
      descripcion: 'Articulo 3',
      codigoBarras: '3456789012345',
      categoria: 'Categoria 3',
      ubicacion: 'Ubicacion 3',
      fabricante: 'Fabricante 3',
      stockInicial: 30,
      precio1: 200.0,
      precio2: 300.0,
      precio3: 400.0,
      iva: 21,
    ),
    Article(
      sku: '456789',
      descripcion: 'Articulo 4',
      codigoBarras: '4567890123456',
      categoria: 'Categoria 4',
      ubicacion: 'Ubicacion 4',
      fabricante: 'Fabricante 4',
      stockInicial: 40,
      precio1: 250.0,
      precio2: 350.0,
      precio3: 450.0,
      iva: 21,
    ),
  ];

  @override
  Future<void> addArticle(Article article) =>
      Future.delayed(const Duration(seconds: 2), () {
        _articles.add(article);
      });

  @override
  Future<void> deleteArticle(String id) {
    // TODO: falta implementar deleteArticle
    throw UnimplementedError();
  }

  @override
  Future<List<Article>> getAllArticles() =>
      Future.delayed(const Duration(seconds: 2), () => _articles);

  @override
  Future<Article?> getArticleById(String sku) => Future.delayed(
    const Duration(seconds: 2),
    () => _articles.firstWhereOrNull((article) => article.sku == sku),
  );

  @override
  Future<List<Article>> searchArticles(
    String query,
  ) => Future.delayed(const Duration(seconds: 2), () {
    if (query.trim().isEmpty) return _articles;

    List<Article> exactResults = _articles;

    final lowerQuery = query.toLowerCase().split(" ");
    for (var element in lowerQuery) {
      if (element.isNotEmpty && element != " ") {
        exactResults =
            _articles.where((article) {
              return article.descripcion.toLowerCase().contains(element) ||
                  article.sku.toLowerCase().contains(element) ||
                  (article.codigoBarras != null &&
                      article.codigoBarras!.toLowerCase().contains(element));
            }).toList();
      }
    }

    return exactResults;
  });

  @override
  Future<void> updateArticle(Article article) {
    // TODO: implement updateArticle
    throw UnimplementedError();
  }
}
