import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  giftPledged,
  giftUnpledged,
  giftPurchased,
}

class NotificationModel {
  final String id;
  final String userId;  // recipient
  final String senderId;  // who triggered the notification
  final String giftId;
  final String giftName;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.senderId,
    required this.giftId,
    required this.giftName,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'senderId': senderId,
    'giftId': giftId,
    'giftName': giftName,
    'type': type.toString(),
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'],
      senderId: data['senderId'],
      giftId: data['giftId'],
      giftName: data['giftName'],
      type: NotificationType.values.firstWhere(
            (e) => e.toString() == data['type'],
      ),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}