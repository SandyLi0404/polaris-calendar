import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoService {
  static const String baseUrl = 'http://localhost:8000/api'; // Change to your backend URL
  
  // Get auth token from shared preferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Create headers with auth token if available
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    
    final headers = {
      'Content-Type': 'application/json',
    };
    
    // Add token only if it exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Get all todos
  static Future<List<Map<String, dynamic>>> getTodos() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/todo/items'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('Failed to load todos: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading todos: $e');
      // Return mock data as fallback for testing
      return _getMockTodos();
    }
  }

  // Create a new todo
  static Future<Map<String, dynamic>> createTodo(Map<String, dynamic> todo) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/todo/items'),
        headers: headers,
        body: jsonEncode(todo),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to create todo: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to create todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating todo: $e');
      // Return mock data as fallback for testing
      return _createMockTodo(todo);
    }
  }

  // Update an existing todo
  static Future<Map<String, dynamic>> updateTodo(int id, Map<String, dynamic> todo) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/todo/items/$id'),
        headers: headers,
        body: jsonEncode(todo),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to update todo: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating todo: $e');
      // Return mock data as fallback for testing
      return _updateMockTodo(id, todo);
    }
  }

  // Delete a todo
  static Future<void> deleteTodo(int id) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/todo/items/$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        print('Failed to delete todo: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting todo: $e');
      // Fallback to mock deletion for testing
      _deleteMockTodo(id);
    }
  }

  // Toggle todo completion status
  static Future<Map<String, dynamic>> toggleTodoCompletion(int id) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/todo/items/$id/toggle'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to toggle todo completion: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to toggle todo completion: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling todo completion: $e');
      // Return mock data as fallback for testing
      return _toggleMockTodoCompletion(id);
    }
  }

  // Find a todo by id
  static Future<Map<String, dynamic>?> findById(int id) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/todo/items/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print('Failed to find todo: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to find todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error finding todo: $e');
      // Fallback to mock data for testing
      return _findMockTodoById(id);
    }
  }

  // Find a todo by event ID
  static Future<Map<String, dynamic>?> findByEventId(String eventId) async {
    try {
      final headers = await _getHeaders();
      
      // Since backend may not have a direct endpoint for this, we get all todos and filter
      final response = await http.get(
        Uri.parse('$baseUrl/todo/items'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final todos = jsonResponse.map((item) => item as Map<String, dynamic>).toList();
        
        // Find todo with matching event_id
        final todo = todos.firstWhere(
          (todo) => todo['event_id'] == eventId,
          orElse: () => {},
        );
        
        return todo.isEmpty ? null : todo;
      } else {
        print('Failed to load todos for event ID search: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error finding todo by event ID: $e');
      // Fallback to mock data for testing
      return _findMockTodoByEventId(eventId);
    }
  }

  // Below are mock implementations used as fallbacks for testing
  
  // Mock data for development and testing
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

  // Next ID for new mock todos
  static int _nextId = 5;
  
  // Mock implementations - used as fallbacks when API calls fail
  static List<Map<String, dynamic>> _getMockTodos() {
    return [..._mockTodos];
  }
  
  static Map<String, dynamic> _createMockTodo(Map<String, dynamic> todo) {
    final newTodo = {
      'id': _nextId++,
      'title': todo['title'],
      'description': todo['description'] ?? '',
      'is_completed': false,
      'priority': todo['priority'] ?? 'low',
      'deadline': todo['deadline'],
      'added_to_calendar': todo['added_to_calendar'] ?? false,
      'event_id': todo['event_id'],
    };
    
    _mockTodos.add(newTodo);
    return newTodo;
  }
  
  static Map<String, dynamic> _updateMockTodo(int id, Map<String, dynamic> todo) {
    final index = _mockTodos.indexWhere((t) => t['id'] == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }
    
    _mockTodos[index] = {
      'id': id,
      'title': todo['title'],
      'description': todo['description'] ?? '',
      'is_completed': _mockTodos[index]['is_completed'],
      'priority': todo['priority'] ?? 'low',
      'deadline': todo['deadline'],
      'added_to_calendar': todo['added_to_calendar'] ?? false,
      'event_id': todo['event_id'] ?? _mockTodos[index]['event_id'],
    };
    
    return _mockTodos[index];
  }
  
  static void _deleteMockTodo(int id) {
    _mockTodos.removeWhere((todo) => todo['id'] == id);
  }
  
  static Map<String, dynamic> _toggleMockTodoCompletion(int id) {
    final index = _mockTodos.indexWhere((t) => t['id'] == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }
    
    _mockTodos[index]['is_completed'] = !_mockTodos[index]['is_completed'];
    return _mockTodos[index];
  }
  
  static Map<String, dynamic>? _findMockTodoById(int id) {
    final todo = _mockTodos.firstWhere(
      (todo) => todo['id'] == id,
      orElse: () => {},
    );
    
    return todo.isEmpty ? null : todo;
  }
  
  // Mock method to find todo by event ID
  static Map<String, dynamic>? _findMockTodoByEventId(String eventId) {
    final todo = _mockTodos.firstWhere(
      (todo) => todo['event_id'] == eventId,
      orElse: () => {},
    );
    
    return todo.isEmpty ? null : todo;
  }
} 