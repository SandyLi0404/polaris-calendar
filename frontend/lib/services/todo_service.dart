import 'dart:async';
import 'package:flutter/foundation.dart';
import '../main.dart';

// Mock Todo service that works without API access
class TodoService {
  // Mock data for development
  static final List<Map<String, dynamic>> _mockTodos = [
    {
      'id': 1,
      'title': 'Complete project proposal',
      'description': 'Finalize the project proposal for the client meeting',
      'is_completed': false,
      'priority': 'high',
      'deadline': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      'added_to_calendar': false,
      'event_id': null,
    },
    {
      'id': 2,
      'title': 'Buy groceries',
      'description': 'Milk, eggs, bread, fruits',
      'is_completed': true,
      'priority': 'normal',
      'deadline': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'added_to_calendar': true,
      'event_id': '1001',
    },
    {
      'id': 3,
      'title': 'Prepare for presentation',
      'description': 'Create slides and practice delivery',
      'is_completed': false,
      'priority': 'high',
      'deadline': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'added_to_calendar': true,
      'event_id': '1002',
    },
    {
      'id': 4,
      'title': 'Call mom',
      'description': '',
      'is_completed': false,
      'priority': 'low',
      'deadline': null,
      'added_to_calendar': false,
      'event_id': null,
    },
  ];

  // Next ID for new todos
  static int _nextId = 5;

  // Get all todos
  static Future<List<Map<String, dynamic>>> getTodos() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return [..._mockTodos];
  }

  // Create a new todo
  static Future<Map<String, dynamic>> createTodo(Map<String, dynamic> todo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newTodo = {
      'id': _nextId++,
      'title': todo['title'],
      'description': todo['description'] ?? '',
      'is_completed': false,
      'priority': todo['priority'] ?? 'normal',
      'deadline': todo['deadline'],
      'added_to_calendar': todo['added_to_calendar'] ?? false,
      'event_id': todo['event_id'],
    };
    
    _mockTodos.add(newTodo);
    return newTodo;
  }

  // Update an existing todo
  static Future<Map<String, dynamic>> updateTodo(int id, Map<String, dynamic> todo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockTodos.indexWhere((t) => t['id'] == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }
    
    _mockTodos[index] = {
      'id': id,
      'title': todo['title'],
      'description': todo['description'] ?? '',
      'is_completed': _mockTodos[index]['is_completed'],
      'priority': todo['priority'] ?? 'normal',
      'deadline': todo['deadline'],
      'added_to_calendar': todo['added_to_calendar'] ?? false,
      'event_id': todo['event_id'] ?? _mockTodos[index]['event_id'],
    };
    
    return _mockTodos[index];
  }

  // Delete a todo
  static Future<void> deleteTodo(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockTodos.removeWhere((todo) => todo['id'] == id);
  }

  // Toggle todo completion status
  static Future<Map<String, dynamic>> toggleTodoCompletion(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockTodos.indexWhere((t) => t['id'] == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }
    
    _mockTodos[index]['is_completed'] = !_mockTodos[index]['is_completed'];
    return _mockTodos[index];
  }

  // Find a todo by event ID
  static Future<Map<String, dynamic>?> findByEventId(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final todo = _mockTodos.firstWhere(
      (todo) => todo['event_id'] == eventId,
      orElse: () => {},
    );
    
    return todo.isEmpty ? null : todo;
  }

  // Find a todo by id
  static Future<Map<String, dynamic>?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final todo = _mockTodos.firstWhere(
      (todo) => todo['id'] == id,
      orElse: () => {},
    );
    
    return todo.isEmpty ? null : todo;
  }
} 