import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all friends with their user details
  Stream<List<UserModel>> getFriends(String userId) {
    return _firestore
        .collection('friends')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final friendIds = snapshot.docs.map((doc) => doc['friendId'] as String).toList();
      if (friendIds.isEmpty) return [];

      final userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      return userDocs.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Add friend
  Future<void> addFriend(String userId, String friendId) async {
    await _firestore.collection('friends').add({
      'userId': userId,
      'friendId': friendId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove friend
  Future<void> removeFriend(String userId, String friendId) async {
    final snapshot = await _firestore
        .collection('friends')
        .where('userId', isEqualTo: userId)
        .where('friendId', isEqualTo: friendId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Check if friendship exists
  Future<bool> checkFriendship(String userId, String friendId) async {
    final snapshot = await _firestore
        .collection('friends')
        .where('userId', isEqualTo: userId)
        .where('friendId', isEqualTo: friendId)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}