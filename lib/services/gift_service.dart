import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift_model.dart';

class GiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'gifts';

  // Create gift
  Future<String> createGift(GiftModel gift) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
        gift.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      throw 'Failed to create gift: ${e.toString()}';
    }
  }

  // Update gift
  Future<void> updateGift(GiftModel gift) async {
    try {
      await _firestore.collection(_collection).doc(gift.id).update(
        gift.toFirestore(),
      );
    } catch (e) {
      throw 'Failed to update gift: ${e.toString()}';
    }
  }

  // Delete gift
  Future<void> deleteGift(String giftId) async {
    try {
      await _firestore.collection(_collection).doc(giftId).delete();
    } catch (e) {
      throw 'Failed to delete gift: ${e.toString()}';
    }
  }

  // Get gift by ID
  Future<GiftModel?> getGiftById(String giftId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(giftId).get();
      if (doc.exists) {
        return GiftModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch gift: ${e.toString()}';
    }
  }

  // Get gifts for an event
  Stream<List<GiftModel>> getEventGifts(String eventId) {
    return _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt', descending: true)
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
        .orderBy('pledgedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GiftModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Pledge gift
  Future<void> updateGiftStatus(String giftId, {
    required GiftStatus newStatus,
    String? pledgedByUserId,
    DateTime? pledgedAt,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add pledge info if provided
      if (pledgedByUserId != null) {
        updates['pledgedByUserId'] = pledgedByUserId;
        updates['pledgedAt'] = pledgedAt ?? FieldValue.serverTimestamp();
      }

      // Remove pledge info if unpledging
      if (newStatus == GiftStatus.available) {
        updates['pledgedByUserId'] = FieldValue.delete();
        updates['pledgedAt'] = FieldValue.delete();
      }

      await _firestore.collection(_collection).doc(giftId).update(updates);
    } catch (e) {
      throw 'Failed to update gift status: ${e.toString()}';
    }
  }
}