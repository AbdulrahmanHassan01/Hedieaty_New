import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus { upcoming, current, past }

class EventModel {
  final String id;
  final String name;
  final String category;
  final DateTime date;
  final String description;
  final String userId;
  final EventStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.description,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'category': category,
    'date': Timestamp.fromDate(date),
    'description': description,
    'userId': userId,
    'status': status.toString(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      status: EventStatus.values.firstWhere(
            (e) => e.toString() == data['status'],
        orElse: () => EventStatus.upcoming,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}