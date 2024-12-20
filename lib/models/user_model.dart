class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'phoneNumber': phoneNumber,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }
}