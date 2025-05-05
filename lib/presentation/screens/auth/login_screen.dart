import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  static const String name = 'login_screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final success = AuthController.login(username, password);
    if (success) {
      context.go('/'); // Navega al home si el login fue exitoso
    } else {
      setState(() {
        _errorMessage = 'Usuario o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                ),
                validator:
                    (value) =>
                        value != null && value.isNotEmpty
                            ? null
                            : 'Ingrese un nombre de usuario',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator:
                    (value) =>
                        value != null && value.length >= 4
                            ? null
                            : 'Contraseña muy corta',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn1',
            child: const Icon(Icons.person_add),
            onPressed: () => context.push('/auth/register'),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'btn2',
            child: const Icon(Icons.lock_reset),
            onPressed: () => context.push('/auth/password-reset'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
