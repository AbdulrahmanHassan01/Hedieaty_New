import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  // Create notification
  Future<void> createNotification(NotificationModel notification) async {
    await _firestore.collection(_collection).add(notification.toFirestore());
  }

  // Get user's notifications
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(_collection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Delete old notifications (cleanup)
  Future<void> deleteOldNotifications(String userId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}