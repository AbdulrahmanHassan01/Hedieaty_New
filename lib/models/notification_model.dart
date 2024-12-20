enum NotificationType { giftPledged }  // Removed friendRequest

class NotificationModel {
  final String id;
  final String userId;      // recipient
  final String senderId;    // sender
  final NotificationType type;
  final String? giftId;
  final String? eventId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.senderId,
    required this.type,
    this.giftId,
    this.eventId,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'senderId': senderId,
    'type': type.toString(),
    'giftId': giftId,
    'eventId': eventId,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      senderId: data['senderId'] ?? '',
      type: NotificationType.values.firstWhere(
            (e) => e.toString() == data['type'],
        orElse: () => NotificationType.giftPledged,
      ),
      giftId: data['giftId'],
      eventId: data['eventId'],
      isRead: data['isRead'] ?? false,
      createdAt: DateTime.parse(data['createdAt']),
    );
  }
}