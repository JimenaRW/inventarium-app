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
  final double? iva;
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
    double? iva,
    bool? activo,
  }) : id = id ?? "",
       precio1 = precio1 ?? 0.0,
       precio2 = precio2 ?? 0.0,
       precio3 = precio3 ?? 0.0,
       iva = iva ?? 0.00,
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
    double? iva,
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
      activo: activo ?? this.activo,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'sku': sku,
      'description': descripcion,
      'barcode': codigoBarras,
      'category': categoria,
      'location': ubicacion,
      'fabricator': fabricante,
      'stock': stock,
      'price1': precio1,
      'price2': precio2,
      'price3': precio3,
      'iva': iva,
      'active': activo,
      'createdAt': DateTime.now(),
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
      descripcion: data?['description'],
      codigoBarras: data?['barcode'],
      categoria: data?['category'],
      ubicacion: data?['location'],
      fabricante: data?['fabricator'],
      stock: data?['stock'],
      precio1: data?['price1'],
      precio2: data?['price2'],
      precio3: data?['price3'],
      iva: data?['iva'],
      activo: data?['active'],
    );
  }

  @override
  String toString() {
    return 'Article: id: $id, sku: $sku, descripción: $descripcion, código de barras: $codigoBarras, categoría: $categoria, ubicación: $ubicacion, fabricante: $fabricante, stock inicial: $stock, precio1: $precio1, precio2: $precio2, precio3: $precio3, iva: $iva, activo: $activo)';
  }
}
