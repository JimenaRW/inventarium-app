import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoryStatus { active, inactive }

class Category {
  String id;
  String descripcion;
  String estado;

  Category({required this.id, required this.descripcion, String? estado})
    : estado = estado ?? CategoryStatus.active.name;

  Category copyWith({String? id, String? descripcion, String? estado}) {
    return Category(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'id': id, 'description': descripcion, 'status': estado};
  }

  static Category fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Category(
      id: data?['id'],
      descripcion: data?['description'],
      estado: data?['status'] ?? CategoryStatus.active.name,
    );
  }

  @override
  String toString() => 'Categoría: $descripcion';
}
