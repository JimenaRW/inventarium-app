import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/i_article_repository.dart';

class ArticleRepository implements IArticleRepository {
  final FirebaseFirestore db;

  ArticleRepository(this.db) : super();

  // final List<Article> _articles = [
  //   Article(
  //     sku: '123456',
  //     descripcion: 'Articulo 1',
  //     codigoBarras: '1234567890123',
  //     categoria: 'Categoria 1',
  //     ubicacion: 'Ubicacion 1',
  //     fabricante: 'Fabricante 1',
  //     stock: 10,
  //     precio1: 100.0,
  //     precio2: 200.0,
  //     precio3: 300.0,
  //     iva: 21,
  //   ),
  //   Article(
  //     sku: '234567',
  //     descripcion: 'Articulo 2',
  //     codigoBarras: '2345678901234',
  //     categoria: 'Categoria 2',
  //     ubicacion: 'Ubicacion 2',
  //     fabricante: 'Fabricante 2',
  //     stock: 20,
  //     precio1: 150.0,
  //     precio2: 250.0,
  //     precio3: 350.0,
  //     iva: 21,
  //   ),
  //   Article(
  //     sku: '345678',
  //     descripcion: 'Articulo 3',
  //     codigoBarras: '3456789012345',
  //     categoria: 'Categoria 3',
  //     ubicacion: 'Ubicacion 3',
  //     fabricante: 'Fabricante 3',
  //     stock: 30,
  //     precio1: 200.0,
  //     precio2: 300.0,
  //     precio3: 400.0,
  //     iva: 21,
  //   ),
  //   Article(
  //     sku: '456789',
  //     descripcion: 'Articulo 4',
  //     codigoBarras: '4567890123456',
  //     categoria: 'Categoria 4',
  //     ubicacion: 'Ubicacion 4',
  //     fabricante: 'Fabricante 4',
  //     stock: 40,
  //     precio1: 250.0,
  //     precio2: 350.0,
  //     precio3: 450.0,
  //     iva: 21,
  //   ),
  // ];

  @override
  Future<Article> addArticle(Article article) async {
    try {
      final doc = db.collection('articles').doc();
      
      final articleFinal = article.copyWith(id: doc.id);

      await doc.set(articleFinal.toFirestore());

      return articleFinal;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteArticle(String id) {
    // TODO: falta implementar deleteArticle
    throw UnimplementedError();
  }

  @override
  Future<List<Article>> getAllArticles() async {
    // Future.delayed(const Duration(seconds: 2), () => _articles);
    try {
      final docs = db
          .collection('articles')
          .withConverter<Article>(
            fromFirestore: Article.fromFirestore,
            toFirestore: (Article article, _) => article.toFirestore(),
          );

      final articles = await docs.get();

      return articles.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<Article?> getArticleById(String sku) =>
      // TODO: implement getArticleById
      throw UnimplementedError();

  @override
  Future<List<Article>> searchArticles(String query) async {
    final docs = db
        .collection('articles')
        .withConverter<Article>(
          fromFirestore: Article.fromFirestore,
          toFirestore: (Article article, _) => article.toFirestore(),
        );

    final articles = await docs.get();

    final _articles = articles.docs.map((doc) => doc.data()).toList();

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
  }

  @override
  Future<void> updateArticle(Article article) {
    // TODO: implement updateArticle
    throw UnimplementedError();
  }

  Future<List<Article>> getArticles() async {
    final docs = db
        .collection('articles')
        .withConverter<Article>(
          fromFirestore: Article.fromFirestore,
          toFirestore: (Article article, _) => article.toFirestore(),
        );

    final articles = await docs.get();

    final _articles = articles.docs.map((doc) => doc.data()).toList();

    return _articles;
  }
}
