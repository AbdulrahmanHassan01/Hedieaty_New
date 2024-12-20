import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';

  // Create event
  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
        event.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      throw 'Failed to create event: ${e.toString()}';
    }
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore.collection(_collection).doc(event.id).update(
        event.toFirestore(),
      );
    } catch (e) {
      throw 'Failed to update event: ${e.toString()}';
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
    } catch (e) {
      throw 'Failed to delete event: ${e.toString()}';
    }
  }

  // Get events for user
  Stream<List<EventModel>> getUserEvents(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch event: ${e.toString()}';
    }
  }

  // Get events by category
  Stream<List<EventModel>> getEventsByCategory(String userId, String category) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Get events by status
  Stream<List<EventModel>> getEventsByStatus(String userId, EventStatus status) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status.toString())
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Get upcoming events in date range
  Stream<List<EventModel>> getUpcomingEventsInRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }
}