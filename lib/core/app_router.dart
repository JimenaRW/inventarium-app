import 'package:go_router/go_router.dart';
import 'package:inventarium/controllers/auth_controller.dart';
import 'package:inventarium/presentation/screens/articles/article_create_screen.dart';
import 'package:inventarium/presentation/screens/articles/articles_screen.dart';
import 'package:inventarium/presentation/screens/auth/login_screen.dart';
import 'package:inventarium/presentation/screens/auth/password_reset_screen.dart';
import 'package:inventarium/presentation/screens/auth/register_screen.dart';
import 'package:inventarium/presentation/screens/categories/categories_screen.dart';
import 'package:inventarium/presentation/screens/categories/category_create_screen.dart';
import 'package:inventarium/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/auth/login',
  redirect: (context, state) {
    final isLoggedIn = AuthController.currentUser != null;
    final location = state.uri.toString();

    final loggingIn = location == '/auth/login' || location == '/auth/register';

    if (!isLoggedIn && !loggingIn) {
      return '/auth/login';
    }

    if (isLoggedIn && loggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      name: LoginScreen.name,
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: RegisterScreen.name,
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
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
      name: ArticleCreateScreen.name,
      path: '/articles/create',
      builder: (context, state) => const ArticleCreateScreen(),
    ),
    GoRoute(
      path: '/auth/logout',
      redirect: (context, state) {
        AuthController.logout();
        return '/auth/login';
      },
    ),
  ],
);
