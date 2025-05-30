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
}