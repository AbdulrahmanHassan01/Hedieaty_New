import 'package:firebase_auth/firebase_auth.dart';
import '../models/gift_model.dart';
import '../models/event_model.dart';
import '../services/gift_service.dart';
import '../services/event_service.dart';

class GiftController {
  final GiftService _giftService = GiftService();
  final EventService _eventService = EventService();

  // Get gifts for an event
  Stream<List<GiftModel>> getEventGifts(String eventId) {
    return _giftService.getEventGifts(eventId);
  }

  // Create new gift
  Future<void> createGift({
    required String eventId,
    required String name,
    required String description,
    required String category,
    required double price,
    String? imageUrl,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    final gift = GiftModel(
      id: '',  // Will be set by Firestore
      name: name,
      description: description,
      category: category,
      price: price,
      eventId: eventId,
      userId: userId,
      imageUrl: imageUrl,
      status: GiftStatus.available,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _giftService.createGift(gift);
    } catch (e) {
      throw 'Failed to create gift: ${e.toString()}';
    }
  }

  // Update gift
  Future<void> editGift({
    required String giftId,
    required String name,
    required String description,
    required String category,
    required double price,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    try {
      final gift = await _giftService.getGiftById(giftId);
      if (gift == null) throw 'Gift not found';

      // Check ownership
      if (gift.userId != userId) {
        throw 'Not authorized to edit this gift';
      }

      // Get event to check status
      final event = await _eventService.getEventById(gift.eventId);
      if (event == null) throw 'Event not found';

      // Only allow editing gifts in upcoming events
      if (event.status != EventStatus.upcoming) {
        throw 'Can only edit gifts in upcoming events';
      }

      final updatedGift = GiftModel(
        id: giftId,
        name: name,
        description: description,
        category: category,
        price: price,
        eventId: gift.eventId,
        userId: userId,
        imageUrl: gift.imageUrl,
        status: gift.status,
        pledgedByUserId: gift.pledgedByUserId,
        pledgedAt: gift.pledgedAt,
        createdAt: gift.createdAt,
        updatedAt: DateTime.now(),
      );

      await _giftService.updateGift(updatedGift);
    } catch (e) {
      throw 'Failed to update gift: ${e.toString()}';
    }
  }

  // Delete gift
  Future<void> deleteGift(String giftId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    try {
      final gift = await _giftService.getGiftById(giftId);
      if (gift == null) throw 'Gift not found';

      if (gift.userId != userId) {
        throw 'Not authorized to delete this gift';
      }

      if (gift.status == GiftStatus.pledged) {
        throw 'Cannot delete a pledged gift';
      }

      await _giftService.deleteGift(giftId);
    } catch (e) {
      throw 'Failed to delete gift: ${e.toString()}';
    }
  }

  // Pledge gift
  Future<void> pledgeGift(String giftId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    try {
      final gift = await _giftService.getGiftById(giftId);
      if (gift == null) throw 'Gift not found';

      if (gift.status == GiftStatus.pledged) {
        throw 'Gift is already pledged';
      }

      if (gift.userId == userId) {
        throw 'Cannot pledge your own gift';
      }

      await _giftService.pledgeGift(giftId, userId);
    } catch (e) {
      throw 'Failed to pledge gift: ${e.toString()}';
    }
  }

  // Unpledge gift
  Future<void> unpledgeGift(String giftId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    try {
      final gift = await _giftService.getGiftById(giftId);
      if (gift == null) throw 'Gift not found';

      if (gift.status != GiftStatus.pledged) {
        throw 'Gift is not pledged';
      }

      if (gift.pledgedByUserId != userId) {
        throw 'Not authorized to unpledge this gift';
      }

      await _giftService.unpledgeGift(giftId);
    } catch (e) {
      throw 'Failed to unpledge gift: ${e.toString()}';
    }
  }

  // Get pledged gifts
  Stream<List<GiftModel>> getUserPledgedGifts() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';
    return _giftService.getUserPledgedGifts(userId);
  }
}