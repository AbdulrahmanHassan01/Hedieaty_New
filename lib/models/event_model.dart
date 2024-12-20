enum EventStatus { upcoming, current, past }

class EventModel {
  final String id;
  final String name;
  final String category;
  final DateTime date;
  final String description;
  final String userId; // owner of the event
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
    'date': date.toIso8601String(),
    'description': description,
    'userId': userId,
    'status': status.toString(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      date: DateTime.parse(data['date']),
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      status: EventStatus.values.firstWhere(
            (e) => e.toString() == data['status'],
        orElse: () => EventStatus.upcoming,
      ),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }
}