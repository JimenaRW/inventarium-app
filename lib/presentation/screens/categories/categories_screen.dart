import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends StatelessWidget {
  static const String name = 'categories_screen';
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/categories/create'),
      ),
    );
  }
}
