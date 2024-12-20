import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationController {
  final NotificationService _notificationService = NotificationService();

  Stream<List<NotificationModel>> getNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';
    return _notificationService.getUserNotifications(userId);
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  // Helper method to create notifications
  Future<void> createGiftStatusNotification({
    required String recipientId,
    required String giftId,
    required String giftName,
    required NotificationType type,
  }) async {
    final senderId = FirebaseAuth.instance.currentUser?.uid;
    if (senderId == null) throw 'User not authenticated';

    final notification = NotificationModel(
      id: '',
      userId: recipientId,
      senderId: senderId,
      giftId: giftId,
      giftName: giftName,
      type: type,
      createdAt: DateTime.now(),
    );

    await _notificationService.createNotification(notification);
  }
}