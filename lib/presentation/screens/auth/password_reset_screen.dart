import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordResetScreen extends StatelessWidget {
  static const String name = 'password_reset_screen';
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(name)),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/auth/login'),
      ),
    );
  }
}
