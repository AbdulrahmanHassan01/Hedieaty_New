import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController {
  final UserService _userService = UserService();

  Future<UserModel?> getCurrentUser() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;
    return await _userService.getUserById(userId);
  }

  Future<UserModel?> findUserByEmail(String email) async {
    return await _userService.getUserByEmail(email);
  }
}