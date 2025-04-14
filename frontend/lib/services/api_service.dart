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
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
} 