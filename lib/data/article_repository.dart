import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
import 'package:inventarium/domain/i_article_repository.dart';
import 'package:inventarium/domain/role.dart';

class ArticleRepository implements IArticleRepository {
  final FirebaseFirestore db;
  final FirebaseStorage _storage;

  ArticleRepository(this.db, this._storage) : super();

  @override
  Future<Article> addArticle(Article article) async {
    try {
      final doc = db.collection('articles').doc();

      final newArticle = article.copyWith(id: doc.id);

      await doc.set(newArticle.toFirestore());

      return newArticle;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteArticle(Article article) async {
    try {
      await db
          .collection('articles')
          .doc(article.id)
          .set(article.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Article>> getAllArticles() async {
    try {
      final docs = db
          .collection('articles')
          .where('status', isEqualTo: ArticleStatus.active.name)
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
  Future<Article?> getArticleById(String id) async {
    final doc =
        await db
            .collection('articles')
            .withConverter<Article>(
              fromFirestore: Article.fromFirestore,
              toFirestore: (Article article, _) => article.toFirestore(),
            )
            .doc(id)
            .get();

    return doc.data();
  }

  @override
  Future<List<Article>> searchArticles(String query) async {
    final docs = db
        .collection('articles')
        .where('status', isEqualTo: ArticleStatus.active.name)
        .withConverter<Article>(
          fromFirestore: Article.fromFirestore,
          toFirestore: (Article article, _) => article.toFirestore(),
        );

    final articles = await docs.get();

    final mappedArticles = articles.docs.map((doc) => doc.data()).toList();

    if (query.trim().isEmpty) return mappedArticles;

    List<Article> exactResults = mappedArticles;

    final lowerQuery = query.toLowerCase().split(" ");
    for (var element in lowerQuery) {
      if (element.isNotEmpty && element != " ") {
        exactResults =
            mappedArticles.where((article) {
              return article.description.toLowerCase().contains(element) ||
                  article.sku.toLowerCase().contains(element) ||
                  (article.barcode != null &&
                      article.barcode!.toLowerCase().contains(element));
            }).toList();
      }
    }

    return exactResults;
  }

  Future<String> uploadArticleImage(File imageFile, String sku) async {
    try {
      final storageRef = _storage.ref();
      final articlesRef = storageRef.child(
        'articles/${FirebaseAuth.instance.currentUser!.uid}/$sku.jpg',
      );
      await articlesRef.putFile(imageFile);
      final downloadUrl = await articlesRef.getDownloadURL();
      return downloadUrl.toString();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateArticle(Article article) async {
    try {
      await db
          .collection('articles')
          .doc(article.id)
          .set(article.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateStock(String id, int newStock) async {
    try {
      await db.collection('articles').doc(id).update({'stock': newStock});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getArticles() async {
    final docs = db
        .collection('articles')
        .where('status', isEqualTo: ArticleStatus.active.name)
        .withConverter<Article>(
          fromFirestore: Article.fromFirestore,
          toFirestore: (Article article, _) => article.toFirestore(),
        );

    final articles = await docs.get();

    final mappedArticles = articles.docs.map((doc) => doc.data()).toList();

    return mappedArticles;
  }

  Future<List<Article>> getArticlesPaginado({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final int offset = (page - 1) * limit;

      final collectionRef = db
          .collection('articles')
          .where('status', isEqualTo: ArticleStatus.active.name)
          .orderBy('createdAt', descending: true);

      QuerySnapshot querySnapshot;

      if (page == 1) {
        querySnapshot = await collectionRef.limit(limit).get();
      } else {
        final previousPageQuery = await collectionRef.limit(offset).get();

        if (previousPageQuery.docs.isEmpty) {
          return [];
        }

        final lastVisible = previousPageQuery.docs.last;

        querySnapshot =
            await collectionRef
                .startAfterDocument(lastVisible)
                .limit(limit)
                .get();
      }

      return querySnapshot.docs.map((doc) {
        return Article.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
          null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  Future<String> exportArticles() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

      final userRole = userDoc.data()!['role'];

      final admin = UserRole.admin.name;
      final editor = UserRole.editor.name;
      final viewer = UserRole.viewer.name;

      if (userRole.toLowerCase() != admin.toLowerCase() ||
          userRole.toLowerCase() != editor.toLowerCase() ||
          userRole.toLowerCase() != viewer.toLowerCase()) {
        return "";
      }

      final querySnapshot =
          await db
              .collection('articles')
              .where('status', isEqualTo: ArticleStatus.active.name)
              .get();

      final mappedArticles =
          querySnapshot.docs.map((doc) {
            return Article.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
              null,
            );
          }).toList();

      final csvContent = _generateArticlesCsv(mappedArticles);

      final fileName =
          'articulos_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      final ref = _storage.ref().child(
        'exports_csv/${userDoc.data()!['id']}/$fileName',
      );

      await ref.putString(csvContent);

      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getArticlesWithNoStock() async {
    try {
      final querySnapshot =
          await db
              .collection('articles')
              .where('stock', isEqualTo: 0)
              .where('status', isEqualTo: ArticleStatus.active.name)
              .withConverter<Article>(
                fromFirestore: Article.fromFirestore,
                toFirestore: (Article article, _) => article.toFirestore(),
              )
              .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getArticlesWithLowStock(int threshold) async {
    try {
      final querySnapshot =
          await db
              .collection('articles')
              .where('stock', isGreaterThan: 0)
              .where('stock', isLessThanOrEqualTo: threshold)
              .where('status', isEqualTo: ArticleStatus.active.name)
              .withConverter<Article>(
                fromFirestore: Article.fromFirestore,
                toFirestore: (Article article, _) => article.toFirestore(),
              )
              .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  String _generateArticlesCsv(List<Article> articles) {
    final buffer = StringBuffer();

    buffer.writeAll([
      'ID',
      'SKU',
      'Descripción',
      'Código de Barras',
      'Categoría',
      'Descripción Categoría',
      'Ubicación',
      'Fabricante',
      'Stock',
      'Precio1',
      'Precio2',
      'Precio3',
      'IVA',
      'Activo',
    ], '\t');
    buffer.writeln();

    for (final article in articles) {
      buffer.writeAll([
        article.id,
        article.sku,
        _escapeCsvField(article.description),
        article.barcode ?? '',
        article.category,
        article.categoryDescription ?? '',
        article.location,
        article.fabricator,
        article.stock,
        article.price1?.toStringAsFixed(2) ?? '0.00',
        article.price2?.toStringAsFixed(2) ?? '0.00',
        article.price3?.toStringAsFixed(2) ?? '0.00',
        article.iva?.toStringAsFixed(2) ?? '0.00',
        article.status,
      ], '\t');
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _escapeCsvField(dynamic field) {
    if (field == null) return '';
    final str = field.toString();
    if (str.contains('"') || str.contains('\t') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }
}
