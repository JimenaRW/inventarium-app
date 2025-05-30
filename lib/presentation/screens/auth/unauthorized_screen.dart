import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/presentation/screens/auth/login_screen.dart';
import 'package:inventarium/presentation/screens/home_screen.dart'; // Importa tu pantalla de login si es necesario

class UnauthorizedScreen extends ConsumerWidget {
  const UnauthorizedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso no autorizado'),
        automaticallyImplyLeading: false, // Oculta el botón de retroceso
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'No tienes permisos para acceder a esta sección',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Contacta al administrador del sistema si necesitas acceso',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla principal o a donde sea apropiado
                  context.goNamed(HomeScreen.name); // Usando go_router
                },
                child: const Text('Volver al inicio'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // Opcional: Cerrar sesión si es necesario
                  // ref.read(authNotifierProvider.notifier).logout();
                  context.goNamed(LoginScreen.name);
                },
                child: const Text('Iniciar sesión con otra cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}