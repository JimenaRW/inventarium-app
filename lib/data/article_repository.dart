import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/i_article_repository.dart';

class ArticleRepository implements IArticleRepository {
  final FirebaseFirestore db;

  ArticleRepository(this.db) : super();

  @override
  Future<Article> addArticle(Article article) async {
    try {
      final doc = db.collection('articles').doc();
      
      final articleFinal = article.copyWith(id: doc.id);

      await doc.set(articleFinal.toFirestore());

      return articleFinal;
    } catch (e) {
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

  Future<List<Article>> getArticlesPaginado({int page = 1, int limit = 20}) async {
    try {
      final int offset = (page - 1) * limit;
      
      final collectionRef = db.collection('articles')
        .orderBy('createdAt', descending: true);

      QuerySnapshot querySnapshot;
      
      if (page == 1) {
        querySnapshot = await collectionRef.limit(limit).get();
      } else {
        final previousPageQuery = await collectionRef
          .limit(offset)
          .get();

        if (previousPageQuery.docs.isEmpty) {
          return [];
        }

        final lastVisible = previousPageQuery.docs.last;
        
        querySnapshot = await collectionRef
          .startAfterDocument(lastVisible)
          .limit(limit)
          .get();
      }

      return querySnapshot.docs.map((doc) {
        return Article.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

}
