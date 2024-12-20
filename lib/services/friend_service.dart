import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'friends';

  // Add friend
  Future<void> addFriend(FriendModel friend) async {
    await _firestore.collection(_collection).add(
      friend.toFirestore(),
    );
  }

  // Remove friend
  Future<void> removeFriend(String userId, String friendId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('friendId', isEqualTo: friendId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Get user's friends
  Stream<List<String>> getUserFriendIds(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => doc.data()['friendId'] as String)
        .toList());
  }
}