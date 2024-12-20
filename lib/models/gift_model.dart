enum GiftStatus { available, pledged }

class GiftModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String eventId;
  final String userId; // owner of the gift
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
    'pledgedAt': pledgedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
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
          ? DateTime.parse(data['pledgedAt'])
          : null,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }
}