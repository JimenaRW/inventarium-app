import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/domain/article.dart'; // Importa el modelo Article

// Mueve la definición de allArticlesProvider fuera de la clase CategoryDashboard
final allArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final articlesRepository = ref.read(articleRepositoryProvider);
  try {
    print("allArticlesProvider: Obteniendo artículos...");
    final articles = await articlesRepository.getAllArticles();
    print("allArticlesProvider: Artículos obtenidos (${articles.length})");
    return articles;
  } catch (error, stackTrace) {
    print(
      "allArticlesProvider: Error al obtener artículos: $error, stackTrace: $stackTrace",
    );
    throw error;
  }
});

// Define un provider para el top 5 de categorías
final topCategoriesProvider =
    StateNotifierProvider<TopCategoriesNotifier, AsyncValue<Map<String, int>>>((
      ref,
    ) {
      return TopCategoriesNotifier(ref);
    });

// Define el Notifier
class TopCategoriesNotifier
    extends StateNotifier<AsyncValue<Map<String, int>>> {
  final Ref _ref;

  TopCategoriesNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Inicializa en loading
    _init();
  }

  Future<void> _init() async {
    try {
      final articlesState = _ref.watch(allArticlesProvider);
      final categoriesState = _ref.watch(categoriesNotifierProvider);

      // Si alguno de los estados es loading, mantenemos el estado en loading
      if (articlesState is AsyncLoading || categoriesState is AsyncLoading) {
        state = const AsyncValue.loading();
        return; // Salimos de la función, no calculamos el top 5 todavía
      }

      // Si alguno de los estados es error, propagamos el error
      if (articlesState is AsyncError) {
        state = AsyncValue.error(
          articlesState.error!,
          articlesState.stackTrace!,
        );
        return;
      }
      if (categoriesState is AsyncError) {
        state = AsyncValue.error(
          categoriesState.error!,
          categoriesState.stackTrace!,
        );
        return;
      }

      final List<Article> articles = articlesState.value ?? [];
      final List<Category> categories = categoriesState.value ?? [];

      // 1. Contar las apariciones de los IDs de las categorías en los artículos.
      final categoryIdCounts = <String, int>{};
      for (final article in articles) {
        if (article.categoria.isNotEmpty) {
          categoryIdCounts.update(
            article.categoria,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      // 2. Crear un nuevo mapa que mapee las descripciones de las categorías a los conteos.
      final categoryDescriptionCounts = <String, int>{};
      for (final category in categories) {
        final count =
            categoryIdCounts[category.id] ??
            0; // Usa el ID para obtener el conteo.
        categoryDescriptionCounts[category.descripcion] = count;
      }
      // 3. Ordenar y filtrar el top 5 con conteo mayor a 0
      final sortedCategoryCounts =
          categoryDescriptionCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      final topCategoriesData = Map.fromEntries(
        sortedCategoryCounts.where((entry) => entry.value > 0).take(5),
      );
      state = AsyncValue.data(
        topCategoriesData,
      ); // Emitimos los datos como AsyncValue.data
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Manejamos errores
    }
  }
}
