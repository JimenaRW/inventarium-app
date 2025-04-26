import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const String name = 'login_screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(name)),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn1',
            child: const Icon(Icons.add),
            onPressed: () => context.push('/auth/register'),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'btn2',
            child: const Icon(Icons.edit),
            onPressed: () => context.push('/auth/password-reset'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
