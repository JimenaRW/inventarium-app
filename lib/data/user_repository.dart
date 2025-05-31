import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventarium/domain/user.dart' as user;
import 'package:inventarium/domain/role.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<user.User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    return doc.exists ? user.User.fromJson(doc.data()!..['id'] = doc.id) : null;
  }

  Future<List<user.User>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => user.User.fromJson(doc.data()..['id'] = doc.id)).toList();
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'role': newRole.toString().split('.').last,
    });
  }

  Future<void> inactivateUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'status': 'inactive',
    });
  }

Future<user.User?> getUserById(String id) async {
  try {
    final doc = await _firestore
        .collection('users')
        .doc(id)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;
    return user.User.fromJson({...data, 'id': doc.id});
  } catch (e) {
    print('Error obteniendo usuario: $e');
    return null;
  }
}

Future<void> updateUserStatus(String userId, String newStatus) async {
  await _firestore.collection('users').doc(userId).update({
    'status': newStatus,
  });
}

}