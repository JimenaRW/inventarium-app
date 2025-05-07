import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String descripcion;

  Category({
    required this.id,
    required this.descripcion});
  
 Category copyWith({
    String? id,
    String? descripcion,
  }) {
    return Category(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }

Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'descripcion': descripcion,
    };
  }

  static Category fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Category(
      id: data?['id'],
      descripcion: data?['descripcion'],
    );
  }


  @override
  String toString() => 'Categoría: $descripcion';
}