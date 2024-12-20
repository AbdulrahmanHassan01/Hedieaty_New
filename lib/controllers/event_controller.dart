import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventController {
  final EventService _eventService = EventService();

  // Get current user's events
  Stream<List<EventModel>> getUserEvents() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';
    return _eventService.getUserEvents(userId);
  }

  // Add this method for getting friend's events
  Stream<List<EventModel>> getFriendEvents(String friendId) {
    return _eventService.getUserEvents(friendId);
  }

  // Create new event
  Future<void> createEvent({
    required String name,
    required String category,
    required DateTime date,
    required String description,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    final event = EventModel(
      id: '',  // Will be set by Firestore
      name: name,
      category: category,
      date: date,
      description: description,
      userId: userId,
      status: _determineEventStatus(date),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _eventService.createEvent(event);
    } catch (e) {
      throw 'Failed to create event: ${e.toString()}';
    }
  }

  // Update event
  Future<void> editEvent({
    required String eventId,
    required String name,
    required String category,
    required DateTime date,
    required String description,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    try {
      final existingEvent = await _eventService.getEventById(eventId);
      if (existingEvent == null) throw 'Event not found';

      if (existingEvent.userId != userId) {
        throw 'Not authorized to edit this event';
      }

      // Check if event is upcoming
      if (existingEvent.status != EventStatus.upcoming) {
        throw 'Only upcoming events can be edited';
      }

      final updatedEvent = EventModel(
        id: eventId,
        name: name,
        category: category,
        date: date,
        description: description,
        userId: userId,
        status: _determineEventStatus(date),
        createdAt: existingEvent.createdAt,
        updatedAt: DateTime.now(),
      );

      await _eventService.updateEvent(updatedEvent);
    } catch (e) {
      throw 'Failed to update event: ${e.toString()}';
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    try {
      final event = await _eventService.getEventById(eventId);
      if (event == null) throw 'Event not found';

      // Verify ownership
      if (event.userId != userId) {
        throw 'Not authorized to delete this event';
      }

      await _eventService.deleteEvent(eventId);
    } catch (e) {
      throw 'Failed to delete event: ${e.toString()}';
    }
  }

  // Helper method to determine event status
  EventStatus _determineEventStatus(DateTime eventDate) {
    final now = DateTime.now();
    final difference = eventDate.difference(now).inDays;

    if (difference > 0) {
      return EventStatus.upcoming;
    } else if (difference == 0) {
      return EventStatus.current;
    } else {
      return EventStatus.past;
    }
  }
}