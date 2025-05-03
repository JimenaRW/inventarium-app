import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/controllers/auth_controller.dart';
import 'package:inventarium/domain/user.dart';

class RegisterScreen extends StatefulWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Role _selectedRole = Role.user;
  String? _errorMessage;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final user = User(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      role: _selectedRole,
    );

    final message = AuthController.register(
      user,
      _confirmPasswordController.text,
    );
    if (message == 'Registro exitoso.') {
      context.go('/');
    } else {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  final emailRegex = RegExp(
                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})*$",
                  );
                  if (value == null || value.isEmpty) {
                    return 'El email es obligatorio';
                  } else if (!emailRegex.hasMatch(value)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                ),
                validator:
                    (value) =>
                        value != null && value.isNotEmpty
                            ? null
                            : 'Campo obligatorio',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator:
                    (value) =>
                        value != null && value.length >= 4
                            ? null
                            : 'Mínimo 4 caracteres',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Repetir Contraseña',
                ),
                validator:
                    (value) =>
                        value != null && value.length >= 4
                            ? null
                            : 'Mínimo 4 caracteres',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Role>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items:
                    Role.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name),
                      );
                    }).toList(),
                onChanged: (role) {
                  if (role != null) {
                    setState(() {
                      _selectedRole = role;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
