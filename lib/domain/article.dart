import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String sku;
  final String descripcion;
  final String? codigoBarras;
  final String categoria;
  final String ubicacion;
  final String fabricante;
  final int stockInicial;
  final double? precio1;
  final double? precio2;
  final double? precio3;
  final int? iva;

  const Article({
    required this.sku,
    required this.descripcion,
    this.codigoBarras,
    required this.categoria,
    required this.ubicacion,
    required this.fabricante,
    required this.stockInicial,
    double? precio1,
    double? precio2,
    double? precio3,
    int? iva,
  }) : precio1 = precio1 ?? 0.0,
       precio2 = precio2 ?? 0.0,
       precio3 = precio3 ?? 0.0,
       iva = iva ?? 0;

  @override
  List<Object?> get props => [
    sku,
    descripcion,
    codigoBarras,
    categoria,
    ubicacion,
    fabricante,
    stockInicial,
    precio1,
    precio2,
    precio3,
    iva,
  ];

  Article copyWith({
    String? sku,
    String? descripcion,
    String? codigoBarras,
    String? categoria,
    String? ubicacion,
    String? fabricante,
    int? stockInicial,
    double? precio1,
    double? precio2,
    double? precio3,
    int? iva,
  }) {
    return Article(
      sku: sku ?? this.sku,
      descripcion: descripcion ?? this.descripcion,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      categoria: categoria ?? this.categoria,
      ubicacion: ubicacion ?? this.ubicacion,
      fabricante: fabricante ?? this.fabricante,
      stockInicial: stockInicial ?? this.stockInicial,
      precio1: precio1 ?? this.precio1,
      precio2: precio2 ?? this.precio2,
      precio3: precio3 ?? this.precio3,
      iva: iva ?? this.iva,
    );
  }

  @override
  String toString() {
    return 'Article: sku: $sku, descripción: $descripcion, código de barras: $codigoBarras, categoría: $categoria, ubicación: $ubicacion, fabricante: $fabricante, stock inicial: $stockInicial, precio1: $precio1, precio2: $precio2, precio3: $precio3, iva: $iva)';
  }
}
