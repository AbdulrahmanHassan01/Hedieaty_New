import 'package:firebase_auth/firebase_auth.dart';
import '../services/gift_service.dart';
import '../models/gift_model.dart';
import '../models/notification_model.dart';
import 'notification_controller.dart';

class GiftController {
  final GiftService _giftService = GiftService();
  final NotificationController _notificationController = NotificationController();

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
      id: '',
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

  // Edit gift
  Future<void> editGift({
    required String giftId,
    required String name,
    required String description,
    required String category,
    required double price,
    String? imageUrl,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    try {
      final gift = await _giftService.getGiftById(giftId);
      if (gift == null) throw 'Gift not found';

      if (gift.userId != userId) {
        throw 'Not authorized to edit this gift';
      }

      if (gift.status != GiftStatus.available) {
        throw 'Can only edit available gifts';
      }

      final updatedGift = GiftModel(
        id: giftId,
        name: name,
        description: description,
        category: category,
        price: price,
        eventId: gift.eventId,
        userId: userId,
        imageUrl: imageUrl,
        status: gift.status,
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

      if (gift.status != GiftStatus.available) {
        throw 'Cannot delete a pledged or purchased gift';
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

      if (gift.userId == userId) {
        throw 'Cannot pledge your own gift';
      }

      if (gift.status != GiftStatus.available) {
        throw 'Gift is not available for pledging';
      }

      await _giftService.updateGiftStatus(
        giftId,
        newStatus: GiftStatus.pledged,
        pledgedByUserId: userId,
      );

      // Create notification
      await _notificationController.createGiftStatusNotification(
        recipientId: gift.userId,
        giftId: giftId,
        giftName: gift.name,
        type: NotificationType.giftPledged,
      );
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

      if (gift.pledgedByUserId != userId) {
        throw 'Not authorized to unpledge this gift';
      }

      if (gift.status == GiftStatus.purchased) {
        throw 'Cannot unpledge a purchased gift';
      }

      await _giftService.updateGiftStatus(
        giftId,
        newStatus: GiftStatus.available,
      );

      // Create notification
      await _notificationController.createGiftStatusNotification(
        recipientId: gift.userId,
        giftId: giftId,
        giftName: gift.name,
        type: NotificationType.giftUnpledged,
      );
    } catch (e) {
      throw 'Failed to unpledge gift: ${e.toString()}';
    }
  }

  // Mark gift as purchased
  Future<void> markGiftAsPurchased(String giftId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    try {
      final gift = await _giftService.getGiftById(giftId);
      if (gift == null) throw 'Gift not found';

      if (gift.pledgedByUserId != userId) {
        throw 'Only the person who pledged can mark as purchased';
      }

      if (gift.status != GiftStatus.pledged) {
        throw 'Only pledged gifts can be marked as purchased';
      }

      await _giftService.updateGiftStatus(
        giftId,
        newStatus: GiftStatus.purchased,
      );

      // Create notification
      await _notificationController.createGiftStatusNotification(
        recipientId: gift.userId,
        giftId: giftId,
        giftName: gift.name,
        type: NotificationType.giftPurchased,
      );
    } catch (e) {
      throw 'Failed to mark gift as purchased: ${e.toString()}';
    }
  }

  // Get user's pledged gifts
  Stream<List<GiftModel>> getUserPledgedGifts() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';
    return _giftService.getUserPledgedGifts(userId);
  }

  Future<GiftModel?> getGiftById(String giftId) async {
    try {
      return await _giftService.getGiftById(giftId);
    } catch (e) {
      throw 'Failed to fetch gift: ${e.toString()}';
    }
  }
}