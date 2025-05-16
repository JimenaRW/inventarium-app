import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/presentation/screens/articles/articles_exports_csv.dart';
import 'package:inventarium/presentation/screens/articles/articles_share_csv.dart';
import 'package:inventarium/presentation/screens/articles/create_article_screen.dart';
import 'package:inventarium/presentation/screens/articles/articles_screen.dart';
import 'package:inventarium/presentation/screens/articles/edit_article_screen.dart';
import 'package:inventarium/presentation/screens/auth/login_screen.dart';
import 'package:inventarium/presentation/screens/auth/password_reset_screen.dart';
import 'package:inventarium/presentation/screens/auth/register_screen.dart';
import 'package:inventarium/presentation/screens/categories/categories_screen.dart';
import 'package:inventarium/presentation/screens/categories/category_create_screen.dart';
import 'package:inventarium/presentation/screens/home_screen.dart';
import 'package:inventarium/presentation/screens/articles/upc_add_screen.dart';

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

final appRouter = GoRouter(
  initialLocation: '/auth/login',
  refreshListenable: _authStreamListenable,
  redirect: (context, state) async {
    // Espera a que Firebase esté listo
    await Firebase.initializeApp();

    final user = FirebaseAuth.instance.currentUser;
    final location = state.uri.toString();
    if (user == null && !location.startsWith('/auth')) {
      return '/auth/login';
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
      name: BarcodeScannerScreen.name,
      path: '/barcode-scanner',
      builder: (context, state) => BarcodeScannerScreen(),
    ),
  ],
);
