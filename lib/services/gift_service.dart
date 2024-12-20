import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift_model.dart';

class GiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'gifts';

  // Create gift
  Future<String> createGift(GiftModel gift) async {
    final docRef = await _firestore.collection(_collection).add(
      gift.toFirestore(),
    );
    return docRef.id;
  }

  // Update gift
  Future<void> updateGift(GiftModel gift) async {
    await _firestore.collection(_collection).doc(gift.id).update(
      gift.toFirestore(),
    );
  }

  // Delete gift
  Future<void> deleteGift(String giftId) async {
    await _firestore.collection(_collection).doc(giftId).delete();
  }

  // Get gifts for an event
  Stream<List<GiftModel>> getEventGifts(String eventId) {
    return _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GiftModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Get user's pledged gifts
  Stream<List<GiftModel>> getUserPledgedGifts(String userId) {
    return _firestore
        .collection(_collection)
        .where('pledgedByUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GiftModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Pledge a gift
  Future<void> pledgeGift(String giftId, String userId) async {
    await _firestore.collection(_collection).doc(giftId).update({
      'status': GiftStatus.pledged.toString(),
      'pledgedByUserId': userId,
      'pledgedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Unpledge a gift
  Future<void> unpledgeGift(String giftId) async {
    await _firestore.collection(_collection).doc(giftId).update({
      'status': GiftStatus.available.toString(),
      'pledgedByUserId': null,
      'pledgedAt': null,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}