import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for the API
  final String baseUrl = 'http://localhost:5001/api';
  
  // Get stored JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Store JWT token
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  // Clear token on logout
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  // Headers with authorization
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'x-auth-token': token ?? '',
    };
  }
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password, bool isTeacher) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'isTeacher': isTeacher,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await setToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required bool isTeacher,
    String? school,
    String? schoolId,
    String? subject,
    int? age,
    String? className,
  }) async {
    try {
      final Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'password': password,
        'isTeacher': isTeacher,
        'schoolId': schoolId ?? '12345', // Default schoolId
      };
      
      // Add teacher-specific fields
      if (isTeacher) {
        userData['school'] = school ?? '';
        userData['subject'] = subject ?? '';
      } 
      // Add student-specific fields
      else {
        userData['age'] = age ?? 0;
        userData['class'] = className ?? '';
        userData['school'] = school ?? '';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await setToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  // Get all students (for teachers/admin)
  Future<List<dynamic>> getStudents() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/students'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get students');
      }
    } catch (e) {
      throw Exception('Failed to get students: $e');
    }
  }
  
  // Get student by ID
  Future<Map<String, dynamic>> getStudentById(String id) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/students/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get student');
      }
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }
  
  // Get student profile
  Future<Map<String, dynamic>> getStudentProfile(String id) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/students/$id/profile'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // If the specific profile endpoint fails, try the general student endpoint
        return getStudentById(id);
      }
    } catch (e) {
      // Fallback to general student endpoint
      return getStudentById(id);
    }
  }
  
  // Get student history
  Future<List<dynamic>> getStudentHistory(String id) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/students/$id/history'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get student history');
      }
    } catch (e) {
      throw Exception('Failed to get student history: $e');
    }
  }
  
  // Get all teachers (for admin)
  Future<List<dynamic>> getTeachers() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/teachers'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get teachers');
      }
    } catch (e) {
      throw Exception('Failed to get teachers: $e');
    }
  }
  
  // Get chat by ID
  Future<Map<String, dynamic>> getChatById(String id) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get chat');
      }
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }
  
  // Get chats by teacher ID
  Future<List<dynamic>> getChatsByTeacher() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/teachers/chats'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get teacher chats');
      }
    } catch (e) {
      throw Exception('Failed to get teacher chats: $e');
    }
  }
  
  // Get chats by student ID
  Future<List<dynamic>> getChatsByStudent(String studentId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/students/$studentId/chats'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get student chats');
      }
    } catch (e) {
      throw Exception('Failed to get student chats: $e');
    }
  }
  
  // Send message to chat
  Future<Map<String, dynamic>> sendMessage(String chatId, String message) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chats/$chatId/messages'),
        headers: headers,
        body: jsonEncode({
          'text': message,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
  
  // Create new chat
  Future<Map<String, dynamic>> createChat(String studentId, String title, {String? initialMessage}) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chats'),
        headers: headers,
        body: jsonEncode({
          'studentId': studentId,
          'title': title,
          'message': initialMessage,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create chat');
      }
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }
  
  // Create history entry
  Future<Map<String, dynamic>> createHistory(String studentId, String subject, {String? topic, String? content, int? score}) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/history'),
        headers: headers,
        body: jsonEncode({
          'studentId': studentId,
          'subject': subject,
          'topic': topic ?? '',
          'content': content ?? '',
          'score': score ?? 0,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create history entry');
      }
    } catch (e) {
      throw Exception('Failed to create history entry: $e');
    }
  }
  
  // Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    try {
      final headers = await getHeaders();
      final userProfile = await getUserProfile();
      final isTeacher = userProfile['isTeacher'] ?? false;
      final endpoint = isTeacher ? 'teachers' : 'students';
      
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint/${userProfile['id']}'),
        headers: headers,
        body: jsonEncode(userData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  // Logout
  Future<void> logout() async {
    await clearToken();
  }
  
  // Get user history
  Future<List<dynamic>> getUserHistory() async {
    try {
      final headers = await getHeaders();
      final userProfile = await getUserProfile();
      final userId = userProfile['_id'] ?? userProfile['id'];
      final isTeacher = userProfile['isTeacher'] ?? false;
      
      if (isTeacher) {
        // For teachers, get all history entries
        final response = await http.get(
          Uri.parse('$baseUrl/history'),
          headers: headers,
        );
        
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception('Failed to get history');
        }
      } else {
        // For students, get only their history
        return getStudentHistory(userId);
      }
    } catch (e) {
      print('Failed to get user history: $e');
      return []; // Return empty list on error
    }
  }
}
