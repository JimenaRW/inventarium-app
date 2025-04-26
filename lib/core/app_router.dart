import 'package:go_router/go_router.dart';
import 'package:inventarium/presentation/screens/articles/article_create_screen.dart';
import 'package:inventarium/presentation/screens/articles/articles_screen.dart';
import 'package:inventarium/presentation/screens/auth/login_screen.dart';
import 'package:inventarium/presentation/screens/auth/password_reset_screen.dart';
import 'package:inventarium/presentation/screens/categories/categories_screen.dart';
import 'package:inventarium/presentation/screens/categories/category_create_screen.dart';
import 'package:inventarium/presentation/screens/home_screen.dart';
import 'package:inventarium/presentation/screens/auth/register_screen.dart';

final appRouter = GoRouter(
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
      builder: (context, state) => PasswordResetScreen(),
    ),
    GoRoute(
      name: HomeScreen.name,
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      name: CategoriesScreen.name,
      path: '/categories',
      builder: (context, state) => CategoriesScreen(),
    ),
    GoRoute(
      name: CategoryCreateScreen.name,
      path: '/categories/create',
      builder: (context, state) => CategoryCreateScreen(),
    ),
    GoRoute(
      name: ArticlesScreen.name,
      path: '/articles',
      builder: (context, state) => ArticlesScreen(),
    ),
    GoRoute(
      name: ArticleCreateScreen.name,
      path: '/articles/create',
      builder: (context, state) => ArticleCreateScreen(),
    ),
  ],
);
