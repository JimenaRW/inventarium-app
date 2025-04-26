import 'package:flutter/material.dart';

class ArticleCreateScreen extends StatelessWidget {
  static const String name = 'article_create_screen';
  const ArticleCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text(name));
  }
}
