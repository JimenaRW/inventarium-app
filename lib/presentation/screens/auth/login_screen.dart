import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/auth_notifier_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/states/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String name = 'login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    ref
        .read(authStateProvider.notifier)
        .signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (authState == AuthState.authenticated) {
      context.go('/');
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Iniciar sesión',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese un correo electrónico';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Iniciar sesión'),
                ),
                if (authState == AuthState.loading)
                  const CircularProgressIndicator(),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    context.go('/auth/register');
                  },
                  child: const Text('¿No tienes cuenta? Registra aquí'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
