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
  
  // Send chat message to the backend
  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final token = await _getToken();
    
    // For single-user mode, we don't need authentication
    final headers = {
      'Content-Type': 'application/json',
    };
    
    // Add token only if it exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot/chat/text'),
      headers: headers,
      body: jsonEncode({
        'message': message,
      }),
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      // For backward compatibility with older version
      if (jsonResponse.containsKey('generated_items')) {
        final generatedItems = jsonResponse['generated_items'];
        return {
          'response': jsonResponse['response'],
          'created_items': generatedItems, // Preserve null if it's null
        };
      } else {
        // New version already uses the correct format
        return jsonResponse;
      }
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
  
  // Clear conversation history
  static Future<void> clearChatHistory() async {
    final token = await _getToken();
    
    // For single-user mode, we don't need authentication
    final headers = {
      'Content-Type': 'application/json',
    };
    
    // Add token only if it exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot/clear-history'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to clear chat history: ${response.statusCode}');
    }
  }
} 