import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class FriendController {
  final FriendService _friendService = FriendService();
  final UserService _userService = UserService();

  // Get all friends
  Stream<List<UserModel>> getFriends() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';
    return _friendService.getFriends(userId);
  }

  // Add friend by email
  Future<void> addFriendByEmail(String email) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw 'User not authenticated';

    // Find user by email
    final friend = await _userService.getUserByEmail(email);
    if (friend == null) throw 'User not found';

    // Can't add yourself as friend
    if (friend.id == currentUserId) {
      throw 'You cannot add yourself as a friend';
    }

    // Check if already friends
    final isAlreadyFriend = await _friendService.checkFriendship(
      currentUserId,
      friend.id,
    );
    if (isAlreadyFriend) {
      throw 'Already in your friends list';
    }

    // Add friend
    await _friendService.addFriend(currentUserId, friend.id);
  }

  // Remove friend
  Future<void> removeFriend(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw 'User not authenticated';
    await _friendService.removeFriend(currentUserId, friendId);
  }
}