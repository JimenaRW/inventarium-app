import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String? id;
  final String sku;
  final String description;
  final String? barcode;
  final String category;
  final String? categoryDescription;
  final String location;
  final String fabricator;
  final int stock;
  final double? price1;
  final double? price2;
  final double? price3;
  final double? iva;
  final String status;
  final String? imageUrl;

  const Article({
    String? id,
    required this.sku,
    required this.description,
    this.barcode,
    required this.category,
    required this.location,
    required this.fabricator,
    required this.stock,
    double? price1,
    double? price2,
    double? price3,
    double? iva,
    String? status,
    String? categoryDescription,
    String? imageUrl,
  }) : id = id ?? "",
       price1 = price1 ?? 0.0,
       price2 = price2 ?? 0.0,
       price3 = price3 ?? 0.0,
       iva = iva ?? 0.00,
       status = status ?? 'active',
       categoryDescription = categoryDescription ?? "",
       imageUrl = imageUrl ?? "";

  @override
  List<Object?> get props => [
    id,
    sku,
    description,
    barcode,
    category,
    location,
    fabricator,
    stock,
    price1,
    price2,
    price3,
    iva,
    status,
  ];

  Article copyWith({
    String? id,
    String? sku,
    String? description,
    String? barcode,
    String? category,
    String? categoryDescription,
    String? location,
    String? fabricator,
    int? stock,
    double? price1,
    double? price2,
    double? price3,
    double? iva,
    String? status,
    String? imageUrl,
  }) {
    return Article(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      categoryDescription: categoryDescription ?? this.categoryDescription,
      location: location ?? this.location,
      fabricator: fabricator ?? this.fabricator,
      stock: stock ?? this.stock,
      price1: price1 ?? this.price1,
      price2: price2 ?? this.price2,
      price3: price3 ?? this.price3,
      iva: iva ?? this.iva,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'sku': sku,
      'description': description,
      'barcode': barcode,
      'category': category,
      'location': location,
      'fabricator': fabricator,
      'stock': stock,
      'price1': price1,
      'price2': price2,
      'price3': price3,
      'iva': iva,
      'status': status,
      'createdAt': DateTime.now(),
      'imageUrl': imageUrl,
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
      description: data?['description'],
      barcode: data?['barcode'],
      category: data?['category'],
      location: data?['location'],
      fabricator: data?['fabricator'],
      stock: data?['stock'],
      price1:
          data?['price1'] is int
              ? (data?['price1'] as int).toDouble()
              : data?['price1'],
      price2:
          data?['price2'] is int
              ? (data?['price2'] as int).toDouble()
              : data?['price2'],
      price3:
          data?['price3'] is int
              ? (data?['price3'] as int).toDouble()
              : data?['price3'],
      iva:
          data?['iva'] is int ? (data?['iva'] as int).toDouble() : data?['iva'],
      status: data?['status'],
      imageUrl: data?['imageUrl'],
    );
  }

  @override
  String toString() {
    return 'Article: id: $id, sku: $sku, descripción: $description, código de barras: $barcode, categoría: $category, ubicación: $location, fabricante: $fabricator, stock inicial: $stock, precio1: $price1, precio2: $price2, precio3: $price3, iva: $iva, estado: $status, imageUrl: $imageUrl';
  }
}
