import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<void> saveUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.id).set(
      user.toMap(), // Changed to toMap()
      SetOptions(merge: true),
    );
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromFirestore(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }
}