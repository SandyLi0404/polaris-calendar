import '../main.dart';

// Event source tracking to prevent circular syncing
enum Source { todo, calendar }

class SyncService {
  // Singleton instance
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // Add a todo to the calendar
  static Event createEventFromTodo(Todo todo) {
    // Generate a tag based on priority
    String tag = 'Personal';
    switch (todo.priority) {
      case 'high':
        tag = 'Work';
        break;
      case 'normal':
        tag = 'Personal';
        break;
      case 'low':
        tag = 'Social';
        break;
    }

    // Create a calendar event from the todo
    DateTime startTime = todo.deadline ?? DateTime.now();
    DateTime endTime = startTime.add(const Duration(hours: 1));

    return Event(
      title: todo.title,
      description: todo.description,
      start: startTime,
      end: endTime,
      color: EventTag.getByName(tag).color,
      tag: tag,
      todoId: todo.id, // Store the todo ID for bidirectional sync
    );
  }

  // Create a todo from a calendar event
  static Todo createTodoFromEvent(Event event) {
    // Map calendar event tag to todo priority
    String priority;
    switch (event.tag.toLowerCase()) {
      case 'work':
        priority = 'high';
        break;
      case 'health':
        priority = 'high';
        break;
      case 'personal':
        priority = 'normal';
        break;
      case 'social':
        priority = 'low';
        break;
      default:
        priority = 'normal';
    }

    return Todo(
      title: event.title,
      description: event.description,
      priority: priority,
      deadline: event.start,
      addedToCalendar: true,
      eventId: event.id, // Store the event ID for bidirectional sync
    );
  }
} 