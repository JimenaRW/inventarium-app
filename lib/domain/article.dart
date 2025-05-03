import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String? id;
  final String sku;
  final String descripcion;
  final String? codigoBarras;
  final String categoria;
  final String ubicacion;
  final String fabricante;
  final int stock;
  final double? precio1;
  final double? precio2;
  final double? precio3;
  final int? iva;
  final bool activo;

  const Article({
    String? id,
    required this.sku,
    required this.descripcion,
    this.codigoBarras,
    required this.categoria,
    required this.ubicacion,
    required this.fabricante,
    required this.stock,
    double? precio1,
    double? precio2,
    double? precio3,
    int? iva,
    bool? activo,
  }) : id = id ?? null,
       precio1 = precio1 ?? 0.0,
       precio2 = precio2 ?? 0.0,
       precio3 = precio3 ?? 0.0,
       iva = iva ?? 0,
       activo = activo ?? true;

  @override
  List<Object?> get props => [
    id,
    sku,
    descripcion,
    codigoBarras,
    categoria,
    ubicacion,
    fabricante,
    stock,
    precio1,
    precio2,
    precio3,
    iva,
    activo,
  ];

  Article copyWith({
    String? id,
    String? sku,
    String? descripcion,
    String? codigoBarras,
    String? categoria,
    String? ubicacion,
    String? fabricante,
    int? stock,
    double? precio1,
    double? precio2,
    double? precio3,
    int? iva,
    bool? activo,
  }) {
    return Article(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      descripcion: descripcion ?? this.descripcion,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      categoria: categoria ?? this.categoria,
      ubicacion: ubicacion ?? this.ubicacion,
      fabricante: fabricante ?? this.fabricante,
      stock: stock ?? this.stock,
      precio1: precio1 ?? this.precio1,
      precio2: precio2 ?? this.precio2,
      precio3: precio3 ?? this.precio3,
      iva: iva ?? this.iva,
      activo: activo ??  this.activo,
    );
  }

  
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'sku': sku,
      'descripcion': descripcion,
      'codigoBarras': codigoBarras,
      'categoria': categoria,
      'ubicacion': ubicacion,
      'fabricante': fabricante,
      'stock': stock,
      'precio1': precio1,
      'precio2': precio2,
      'precio3': precio3,
      'iva': iva,
      'activo': activo,
    };
  }

  static Article fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Article(
      id: data?['id'],
      sku: data?['sku'],
      descripcion: data?['descripcion'],
      codigoBarras: data?['codigoBarras'],
      categoria: data?['categoria'],
      ubicacion: data?['ubicacion'],
      fabricante: data?['fabricante'],
      stock: data?['stock'],
      precio1: data?['precio1'],
      precio2: data?['precio2'],
      precio3: data?['precio3'],
      iva: data?['iva'],
      activo: data?['activo'],
    );
  }

  @override
  String toString() {
    return 'Article: id: $id, sku: $sku, descripción: $descripcion, código de barras: $codigoBarras, categoría: $categoria, ubicación: $ubicacion, fabricante: $fabricante, stock inicial: $stock, precio1: $precio1, precio2: $precio2, precio3: $precio3, iva: $iva, activo: $activo)';
  }
}
