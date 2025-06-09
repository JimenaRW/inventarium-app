import 'package:inventarium/domain/article.dart';

abstract interface class IArticleRepository{
  Future<List<Article>> getAllArticles();
  Future<Article?> getArticleById(String sku);
  Future<void> addArticle(Article article);
  Future<void> updateArticle(Article article);
  Future<void> deleteArticle(Article article);
  Future<List<Article?>> searchArticles(String query);
  Future<void> updateStock(String id, int newStock);
}