import 'package:flutter/material.dart';

class CategoryCreateScreen extends StatelessWidget {
  static const String name = 'category_create_screen';
  const CategoryCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text(name)));
  }
}
