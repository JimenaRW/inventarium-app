import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoryStatus { active, inactive }

class Category {
  String id;
  String description;
  String status;

  Category({required this.id, required this.description, String? status})
    : status = status ?? CategoryStatus.active.name;

  Category copyWith({String? id, String? description, String? status}) {
    return Category(
      id: id ?? this.id,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'id': id, 'description': description, 'status': status};
  }

  static Category fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Category(
      id: data?['id'],
      description: data?['description'],
      status: data?['status'] ?? CategoryStatus.active.name,
    );
  }

  @override
  String toString() => 'Categoría: $description';
}
