class FriendModel {
  final String id;
  final String userId;      // The user who added the friend
  final String friendId;    // The friend being added
  final DateTime addedAt;   // When the friend was added

  FriendModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.addedAt,
  });

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'friendId': friendId,
    'addedAt': addedAt.toIso8601String(),
  };

  factory FriendModel.fromFirestore(Map<String, dynamic> data, String id) {
    return FriendModel(
      id: id,
      userId: data['userId'] ?? '',
      friendId: data['friendId'] ?? '',
      addedAt: DateTime.parse(data['addedAt']),
    );
  }
}