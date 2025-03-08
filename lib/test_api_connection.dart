import 'package:flutter/material.dart';
import 'services/api_service.dart';

class TestApiConnection extends StatefulWidget {
  const TestApiConnection({Key? key}) : super(key: key);

  @override
  _TestApiConnectionState createState() => _TestApiConnectionState();
}

class _TestApiConnectionState extends State<TestApiConnection> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _result = '';
  
  // Test login
  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing login...';
    });
    
    try {
      final response = await _apiService.login(
        'testteacher@example.com', 
        'password123', 
        true
      );
      
      setState(() {
        _result = 'Login successful: ${response['user']['name']}';
      });
    } catch (e) {
      setState(() {
        _result = 'Login failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Test get user profile
  Future<void> _testGetProfile() async {
    setState(() {
      _isLoading = true;
      _result = 'Getting user profile...';
    });
    
    try {
      final response = await _apiService.getUserProfile();
      
      setState(() {
        _result = 'Profile retrieved: ${response['name']}, ${response['email']}';
      });
    } catch (e) {
      setState(() {
        _result = 'Failed to get profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Test get students
  Future<void> _testGetStudents() async {
    setState(() {
      _isLoading = true;
      _result = 'Getting students...';
    });
    
    try {
      final response = await _apiService.getStudents();
      
      setState(() {
        _result = 'Students retrieved: ${response.length} students';
      });
    } catch (e) {
      setState(() {
        _result = 'Failed to get students: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Test create chat
  Future<void> _testCreateChat() async {
    setState(() {
      _isLoading = true;
      _result = 'Creating chat...';
    });
    
    try {
      // Use the ID of our test student
      final response = await _apiService.createChat(
        '67cc78cfc1392ce85972351f',
        'Test Chat from Flutter',
        initialMessage: 'Hello from Flutter app!'
      );
      
      setState(() {
        _result = 'Chat created with ID: ${response['_id']}';
      });
    } catch (e) {
      setState(() {
        _result = 'Failed to create chat: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MongoDB API Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: const Text('Test Login'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetProfile,
              child: const Text('Test Get Profile'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetStudents,
              child: const Text('Test Get Students'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCreateChat,
              child: const Text('Test Create Chat'),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(),
            const SizedBox(height: 16),
            Text(
              'Result:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
