import 'package:cloud_firestore/cloud_firestore.dart';

enum GiftStatus { available, pledged, purchased }

class GiftModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String eventId;
  final String userId;
  final String? imageUrl;
  final GiftStatus status;
  final String? pledgedByUserId;
  final DateTime? pledgedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  GiftModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.eventId,
    required this.userId,
    this.imageUrl,
    required this.status,
    this.pledgedByUserId,
    this.pledgedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'eventId': eventId,
    'userId': userId,
    'imageUrl': imageUrl,
    'status': status.toString(),
    'pledgedByUserId': pledgedByUserId,
    'pledgedAt': pledgedAt != null ? Timestamp.fromDate(pledgedAt!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory GiftModel.fromFirestore(Map<String, dynamic> data, String id) {
    return GiftModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'],
      status: GiftStatus.values.firstWhere(
            (e) => e.toString() == data['status'],
        orElse: () => GiftStatus.available,
      ),
      pledgedByUserId: data['pledgedByUserId'],
      pledgedAt: data['pledgedAt'] != null
          ? (data['pledgedAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}