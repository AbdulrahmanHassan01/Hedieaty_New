import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';

  // Create event
  Future<String> createEvent(EventModel event) async {
    final docRef = await _firestore.collection(_collection).add(
      event.toFirestore(),
    );
    return docRef.id;
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    await _firestore.collection(_collection).doc(event.id).update(
      event.toFirestore(),
    );
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collection).doc(eventId).delete();
  }

  // Get user's events
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
    final doc = await _firestore.collection(_collection).doc(eventId).get();
    if (doc.exists) {
      return EventModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }
}