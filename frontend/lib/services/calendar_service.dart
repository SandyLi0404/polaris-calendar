import '../main.dart';

// Mock Calendar service for development
class CalendarService {
  // In-memory collection of events
  static final List<Event> _events = [...sampleEvents];

  // Get all events
  static Future<List<Event>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [..._events];
  }

  // Add a new event
  static Future<Event> addEvent(Event event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _events.add(event);
    return event;
  }

  // Update an existing event
  static Future<Event> updateEvent(String id, Event event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw Exception('Event not found');
    }
    
    _events[index] = event;
    return event;
  }

  // Delete an event
  static Future<void> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _events.removeWhere((event) => event.id == id);
  }

  // Find an event by id
  static Future<Event?> findById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Find an event by todo id
  static Future<Event?> findByTodoId(int todoId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _events.firstWhere((event) => event.todoId == todoId);
    } catch (e) {
      return null;
    }
  }

  // Get today's events
  static Future<List<Event>> getTodayEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _events.where((event) {
      final eventDate = DateTime(
        event.start.year, 
        event.start.month, 
        event.start.day
      );
      return eventDate.isAtSameMomentAs(today) || 
             (event.isAllDay && eventDate.isBefore(tomorrow) && event.end.isAfter(today));
    }).toList();
  }
} 