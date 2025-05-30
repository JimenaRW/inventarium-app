import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/navigation_provider.dart';
import 'package:inventarium/domain/user.dart' as domain;
import 'package:inventarium/presentation/screens/articles/articles_exports_csv.dart';
import 'package:inventarium/presentation/screens/articles/articles_import_csv.dart';
import 'package:inventarium/presentation/screens/articles/articles_share_csv.dart';
import 'package:inventarium/presentation/screens/articles/articles_stock_screen.dart';
import 'package:inventarium/presentation/screens/articles/create_article_screen.dart';
import 'package:inventarium/presentation/screens/articles/articles_screen.dart';
import 'package:inventarium/presentation/screens/articles/delete_article_screen.dart';
import 'package:inventarium/presentation/screens/articles/delete_category_screen.dart';
import 'package:inventarium/presentation/screens/articles/edit_article_screen.dart';
import 'package:inventarium/presentation/screens/auth/login_screen.dart';
import 'package:inventarium/presentation/screens/auth/password_reset_screen.dart';
import 'package:inventarium/presentation/screens/auth/register_screen.dart';
import 'package:inventarium/presentation/screens/auth/unauthorized_screen.dart';
import 'package:inventarium/presentation/screens/categories/categories_screen.dart';
import 'package:inventarium/presentation/screens/categories/category_create_screen.dart';
import 'package:inventarium/presentation/screens/categories/edit_category_screen.dart';
import 'package:inventarium/presentation/screens/home_screen.dart';
import 'package:inventarium/presentation/screens/theme/theme_screen.dart';
import 'package:inventarium/presentation/screens/users/edit_user_screen.dart';
import 'package:inventarium/presentation/screens/users/users_screen.dart';

class AuthStreamListenable extends ChangeNotifier {
  StreamSubscription<User?>? _subscription; // Hacerlo nullable



  AuthStreamListenable() {
    init();
  }

  Future<void> init() async {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Cancelar solo si existe
    super.dispose();
  }
}

final _authStreamListenable = AuthStreamListenable();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

   final restrictedRoutes = {
    'viewer': ['/edit', '/create', '/delete', '/users','/import-csv','/stock'],
    'editor': ['/users'], // 'editor' no puede acceder a usuarios ni borrar
    // 'admin' no tiene restricciones
  };

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth/login',
    refreshListenable: _authStreamListenable,
    redirect: (context, state) async {
      await Firebase.initializeApp();
      final user = FirebaseAuth.instance.currentUser;
      final location = state.uri.toString();
      if (user == null && !location.startsWith('/auth')) {
        return '/auth/login';
      }

      // Si hay usuario autenticado
      if (user != null) {
        // Obtener el documento del usuario en Firestore para verificar su rol
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        final userRole = userDoc.data()?['role'] as String?;

        if (userRole == null) {
          return '/unauthorized';
        }

        final userRestrictions = restrictedRoutes[userRole] ?? [];
        if (userRestrictions.any((route) => location.contains(route))) {
          return '/unauthorized';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        name: LoginScreen.name,
        path: '/auth/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        name: RegisterScreen.name,
        path: '/auth/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        name: PasswordResetScreen.name,
        path: '/auth/password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        name: HomeScreen.name,
        path: '/',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        name: CategoriesScreen.name,
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        name: CategoryCreateScreen.name,
        path: '/categories/create',
        builder: (context, state) => const CategoryCreateScreen(),
      ),
      GoRoute(
        name: ArticlesScreen.name,
        path: '/articles',
        builder: (context, state) => const ArticlesScreen(),
      ),
      GoRoute(
        name: CreateArticleScreen.name,
        path: '/articles/create',
        builder: (context, state) => const CreateArticleScreen(),
      ),
      GoRoute(
        name: EditArticleScreen.name,
        path: '/articles/edit/:id',
        builder:
            (context, state) =>
                EditArticleScreen(id: state.pathParameters['id'] ?? ""),
      ),
      GoRoute(
        name: DeleteArticleScreen.name,
        path: '/articles/delete/:id',
        builder:
            (context, state) => DeleteArticleScreen(
              articleId: state.pathParameters['id'] ?? "",
            ),
      ),
      GoRoute(
        path: '/articles/exports-csv',
        name: ArticlesExportsCsv.name,
        builder: (context, state) => const ArticlesExportsCsv(),
      ),
      GoRoute(
        path: '/articles/share-csv',
        name: ArticlesShareCsv.name,
        builder: (context, state) => const ArticlesShareCsv(),
      ),
      GoRoute(
        path: '/articles/import-csv',
        name: ArticlesImportCsv.name,
        builder: (context, state) => const ArticlesImportCsv(),
      ),
      GoRoute(
        name: EditCategoryScreen.name,
        path: '/categories/edit/:id',
        builder:
            (context, state) =>
                EditCategoryScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        name: DeleteCategoryScreen.name,
        path: '/categories/delete/:id',
        builder:
            (context, state) => DeleteCategoryScreen(
              categoryId: state.pathParameters['id'] ?? '',
            ),
      ),
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized_screen',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      GoRoute(
        path: '/users',
        name: 'users_screen',
        builder: (context, state) {
          return const UsersScreen();
        },
      ),
      GoRoute(
        name: StockScreen.name,
        path: '/stock',
        builder: (context, state) => StockScreen(),
      ),
      GoRoute(
        name: ThemeScreen.name,
        path: '/theme',
        builder: (context, state) => ThemeScreen(),
      ),
      GoRoute(
        name: EditUserScreen.name,
        path: '/users/edit/:id',
        builder: (context, state) {
          final user = state.extra as domain.User;
          return EditUserScreen(user: user);
        },
      ),
    ],
    observers: [ref.read(routeObserverProvider)],
  ),
);
