import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/core/app_router.dart';
import 'package:inventarium/data/theme_provider.dart';
import 'package:inventarium/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(
      appRouterProvider,
    ); // Usa appRouterProvider aquí
    final appTheme = ref.watch(themeNotifierProvider);
    
    return MaterialApp.router(title: 'Inventarium', routerConfig: appRouter, theme: appTheme.getTheme(),);
  }
}
