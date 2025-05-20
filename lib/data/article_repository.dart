import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inventarium/domain/article.dart';
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

  Future<List<Article>> getArticlesPaginado({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final int offset = (page - 1) * limit;

      final collectionRef = db
          .collection('articles')
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
      // 1. Verifica el rol en Firestore antes de subir:
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

      final userRole = userDoc.data()!['role']; // 'admin', 'user', etc.
      final admin = UserRole.admin.name;
      if (userRole.toLowerCase() != admin.toLowerCase()) {
        return "";
      }

      final querySnapshot = await db.collection('articles').get();
      final articles =
          querySnapshot.docs.map((doc) {
            return Article.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
              null,
            );
          }).toList();

      // 2. Generar contenido CSV
      final csvContent = _generateCsvContent(articles);

      // 3. Subir a Firebase Storage
      final fileName =
          'articulos_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final ref = _storage.ref().child(
        'exports_csv/${userDoc.data()!['id']}/$fileName',
      );

      await ref.putString(csvContent);

      // 4. Obtener URL de descarga
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Nuevo método para obtener artículos con stock 0
  Future<List<Article>> getArticlesWithNoStock() async {
    try {
      final querySnapshot =
          await db
              .collection('articles')
              .where('stock', isEqualTo: 0)
              .withConverter<Article>(
                fromFirestore: Article.fromFirestore,
                toFirestore: (Article article, _) => article.toFirestore(),
              )
              .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting articles with no stock: $e');
      rethrow; // Importante: relanza la excepción para que Riverpod la maneje
    }
  }

  Future<List<Article>> getArticlesWithLowStock(int threshold) async {
    try {
      final querySnapshot =
          await db
              .collection('articles')
              .where('stock', isLessThanOrEqualTo: threshold, isNotEqualTo: 0)
              .withConverter<Article>(
                fromFirestore: Article.fromFirestore,
                toFirestore: (Article article, _) => article.toFirestore(),
              )
              .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting articles with low stock: $e');
      rethrow;
    }
  }

  String _generateCsvContent(List<Article> articles) {
    final buffer = StringBuffer();

    // Escribir encabezado
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

    // Escribir filas
    for (final article in articles) {
      buffer.writeAll([
        article.id,
        article.sku,
        _escapeCsvField(article.descripcion),
        article.codigoBarras ?? '',
        article.categoria,
        article.categoriaDescripcion ?? '',
        article.ubicacion,
        article.fabricante,
        article.stock,
        article.precio1?.toStringAsFixed(2) ?? '0.00',
        article.precio2?.toStringAsFixed(2) ?? '0.00',
        article.precio3?.toStringAsFixed(2) ?? '0.00',
        article.iva?.toStringAsFixed(2) ?? '0.00',
        article.activo,
      ], '\t');
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _escapeCsvField(dynamic field) {
    if (field == null) return '';
    final str = field.toString();
    // Escapar comillas y saltos de línea si es necesario
    if (str.contains('"') || str.contains('\t') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }
}
