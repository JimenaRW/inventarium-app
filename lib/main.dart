import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inventarium/core/app_router.dart';
import 'package:inventarium/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configuración de debug para Firebase Auth
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true, // Solo para desarrollo
    forceRecaptchaFlow: false, // Opcional: deshabilita Recaptcha en debug
  );
  
  // Habilita logging detallado
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099); // Para usar emulador
  debugPrint('Firebase Auth configurado en modo debug');
  
  // await cargarDatosDePruebaCategoria();
  // await cargarDatosDePrueba();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(title: 'Inventarium', routerConfig: appRouter),
    );
  }
}

// Future<void> cargarDatosDePruebaCategoria() async {
//   final firestore = FirebaseFirestore.instance;
  
//   // Datos base para generar contenido aleatorio
//   const categorias = [
//     'Smartphones',
//     'Laptops',
//     'Tablets',
//     'Televisores',
//     'Audio',
//     'Gaming',
//     'Fotografía',
//     'Smart Home',
//     'Componentes PC',
//     'Accesorios',
//     'Wearables',
//     'Drones',
//     'Almacenamiento',
//     'Redes',
//     'Oficina',
//   ];

//   for (var categoria in categorias) {
//     final docRef =
//         firestore
//             .collection('categories')
//             .doc(); // Crea referencia con ID auto-generado
//     final id = docRef.id; // Obtiene el ID antes de guardar
//     await docRef.set({'id': id, 'description': categoria});
//   }
// }

Future<void> cargarDatosDePrueba() async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // Datos base para generar contenido aleatorio
  const categorias = [
    'Smartphones',
    'Laptops',
    'Tablets',
    'Televisores',
    'Audio',
    'Gaming',
    'Fotografía',
    'Smart Home',
    'Componentes PC',
    'Accesorios',
    'Wearables',
    'Drones',
    'Almacenamiento',
    'Redes',
    'Oficina',
  ];
  const fabricantes = [
    // Marcas globales
    'Sony',
    'Samsung',
    'LG',
    'Apple',
    'Xiaomi',
    'Huawei',

    // Computación
    'Dell',
    'HP',
    'Lenovo',
    'Asus',
    'Acer',
    'MSI',

    // Audio y gaming
    'Bose',
    'JBL',
    'Sennheiser',
    'Razer',
    'Logitech',
    'SteelSeries',

    // TV y pantallas
    'TCL',
    'Hisense',
    'Panasonic',
    'Philips',

    // Componentes
    'Intel',
    'AMD',
    'NVIDIA',
    'Corsair',

    // Otros
    'GoPro',
    'DJI',
    'Fitbit',
    'Garmin',
  ];
  const ubicaciones = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  const palabrasDescriptivas = [
    'Premium',
    'Económico',
    'Profesional',
    'Delgado',
    'Ergonómico',
    'Inalámbrico',
    'Inteligente',
    'Sostenible',
    'Compacto',
  ];
  const productosBase = [
    // Smartphones
    'Galaxy S23 Ultra',
    'iPhone 15 Pro',
    'Xiaomi Redmi Note 12',
    'Huawei P60 Pro',

    // Laptops
    'MacBook Pro M2',
    'Dell XPS 15',
    'Lenovo ThinkPad X1',
    'Asus ROG Zephyrus',

    // Televisores
    'LG OLED C3',
    'Samsung QN90B Neo QLED',
    'Sony Bravia XR A80K',

    // Audio
    'AirPods Pro 2',
    'Sony WH-1000XM5',
    'Bose QuietComfort 45',

    // Gaming
    'PlayStation 5',
    'Xbox Series X',
    'Nintendo Switch OLED',

    // Componentes
    'NVIDIA RTX 4090',
    'Intel Core i9-13900K',
    'Samsung 980 Pro SSD 1TB',

    // Smart Home
    'Google Nest Hub',
    'Amazon Echo Dot',
    'Philips Hue Starter Kit',

    // Wearables
    'Apple Watch Ultra',
    'Samsung Galaxy Watch 5',
    'Fitbit Charge 6',
  ];

  for (int i = 0; i < 70; i++) {
    final sku = generarSkuCorto(random);
    final descripcion =
        '${palabrasDescriptivas[random.nextInt(palabrasDescriptivas.length)]} '
        '${productosBase[random.nextInt(productosBase.length)]}';
    final codigoBarras =
        '${random.nextInt(900000) + 100000}${random.nextInt(900000) + 100000}';
    final categoria = categorias[random.nextInt(categorias.length)];
    final ubicacion = ubicaciones[random.nextInt(ubicaciones.length)];
    final fabricante = fabricantes[random.nextInt(fabricantes.length)];
    final stock = random.nextInt(100);
    final precioBase = 10 + random.nextDouble() * 100;
    final iva = [0, 10, 21][random.nextInt(3)];
    final activo = random.nextBool();

    final docRef =
        firestore
            .collection('articles')
            .doc(); // Crea referencia con ID auto-generado
    final id = docRef.id; // Obtiene el ID antes de guardar

    await docRef.set({
      'id': id,
      'sku': sku,
      'description': descripcion,
      'barcode': codigoBarras,
      'category': categoria,
      'location': ubicacion,
      'fabricator': fabricante,
      'stock': stock,
      'price1': double.parse(precioBase.toStringAsFixed(2)),
      'price2': double.parse((precioBase * 0.9).toStringAsFixed(2)),
      'price3': double.parse((precioBase * 0.8).toStringAsFixed(2)),
      'iva': iva,
      'active': activo,
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('Artículo creado: $sku - $descripcion');
  }
  print('✅ 30 artículos de prueba creados exitosamente');
}

String generarSkuCorto(Random random) {
  const caracteres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final longitud = 4 + random.nextInt(5); // Entre 4 y 8 caracteres
  return List.generate(
    longitud,
    (index) => caracteres[random.nextInt(caracteres.length)],
  ).join();
}
