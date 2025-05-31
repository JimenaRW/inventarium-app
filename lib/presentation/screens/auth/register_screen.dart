import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/auth_notifier_provider.dart'; //
import 'package:inventarium/presentation/viewmodels/article/states/auth_state.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const String name = 'register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submit() async {
    final form = _formKey.currentState;
    if (form == null || !_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    try {
      await ref
          .read(authStateProvider.notifier)
          .registerWithEmail(_emailController.text, _passwordController.text);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      ref.read(authStateProvider.notifier).reset();
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'invalid-email-verified':
        message =
            'Por favor verifica tu correo electrónico antes de iniciar sesión';
        break;
      case 'wrong-password':
      case 'user-not-found':
        message = 'Correo electrónico o contraseña incorrectos';
        break;
      case 'too-many-requests':
        message = 'Demasiados intentos. Por favor intenta más tarde';
        break;
      case 'email-already-in-use':
        message = 'El mail esta en uso';
        break;
      default:
        message = 'Error al iniciar sesión: ${e.message}';
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next == AuthState.authenticated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Usuario creado con exito!")));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/');
        });
      }
    });

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
                  'Registrarse',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El email es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La confirmación de contraseña es obligatoria';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Registrarse'),
                ),
                if (authState == AuthState.loading)
                  const CircularProgressIndicator(),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    context.go('/auth/login'); // Navega a la pantalla de login
                  },
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
