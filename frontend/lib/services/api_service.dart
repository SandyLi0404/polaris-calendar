import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // Change to your backend URL
  
  // Get auth token from shared preferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Test authentication with backend
  static Future<bool> testAuth() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      
      // Try to access a simple protected endpoint
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/debug'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Send chat message to the backend
  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return {
        'response': 'You need to log in first',
        'generated_items': null,
        'error': 'Not authenticated'
      };
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/chat/text'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Handle authentication error
        return {
          'response': 'Your session has expired. Please log in again.',
          'generated_items': null,
          'error': 'Authentication failed'
        };
      } else {
        final errorMsg = 'Failed to send message: ${response.statusCode}';
        String errorDetails = '';
        
        try {
          // Try to parse error details from response body
          final errorBody = jsonDecode(response.body);
          if (errorBody.containsKey('detail')) {
            errorDetails = ' - ${errorBody['detail']}';
          }
        } catch (_) {}
        
        throw Exception('$errorMsg$errorDetails');
      }
    } catch (e) {
      return {
        'response': 'Error: ${e.toString()}',
        'generated_items': null,
        'error': e.toString()
      };
    }
  }
} 