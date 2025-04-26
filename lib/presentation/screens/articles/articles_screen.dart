import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArticlesScreen extends StatelessWidget {
  static const String name = 'articles_screen';
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(name)),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/articles/create'),
      ),
    );
  }
}
