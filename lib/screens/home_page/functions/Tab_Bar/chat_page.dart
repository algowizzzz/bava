import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/chatModel.dart';
import '../../../../services/api_service.dart';

class ChatPage extends StatefulWidget {
  final String className;
  final String subjects;

  const ChatPage({Key? key, required this.className, required this.subjects}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ApiService _apiService = ApiService();
  String _currentUserId = 'guest';
  String _currentUserName = '';
  bool _isTeacher = true;
  List<ChatModel> _chatList = [];
  String _chatId = '';

  // Function to send a message using MongoDB API
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // If we don't have a chat ID yet, create a new chat
      if (_chatId.isEmpty) {
        // Get student ID from the first student in the class
        final students = await _apiService.getStudents();
        if (students.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No students found to create chat with')),
          );
          return;
        }
        
        final studentId = students[0]['_id'];
        final chatTitle = '${widget.subjects} - ${widget.className}';
        
        final response = await _apiService.createChat(
          studentId,
          chatTitle,
          initialMessage: text,
        );
        
        _chatId = response['_id'];
        
        // Add the message to our local chat list
        final newMessage = ChatModel(
          senderId: _currentUserId,
          text: text,
          messageType: 'text',
          isDeleted: false,
          isRead: false,
          currentDateTime: DateTime.now(),
          documents: [],
          className: widget.className,
          subject: widget.subjects,
        );
        
        setState(() {
          _chatList.insert(0, newMessage);
        });
      } else {
        // Send message to existing chat
        final response = await _apiService.sendMessage(_chatId, text);
        
        // Add the message to our local chat list
        final newMessage = ChatModel(
          senderId: _currentUserId,
          text: text,
          messageType: 'text',
          isDeleted: false,
          isRead: false,
          currentDateTime: DateTime.now(),
          documents: [],
          className: widget.className,
          subject: widget.subjects,
        );
        
        setState(() {
          _chatList.insert(0, newMessage);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }
  // Load messages from MongoDB API
  Future<void> _loadMessages() async {
    try {
      // Find existing chat for this class and subject
      final chats = _isTeacher 
          ? await _apiService.getChatsByTeacher()
          : await _apiService.getChatsByStudent(_currentUserId);
      
      // Filter chats by title (which contains class and subject)
      final filteredChats = chats.where((chat) {
        final title = chat['title'] ?? '';
        return title.contains(widget.className) && title.contains(widget.subjects);
      }).toList();
      
      if (filteredChats.isNotEmpty) {
        // Use the first matching chat
        final chat = filteredChats[0];
        _chatId = chat['_id'];
        
        // Get chat messages
        final chatData = await _apiService.getChatById(_chatId);
        final messages = chatData['messages'] ?? [];
        
        setState(() {
          _chatList = messages.map((data) => ChatModel(
            senderId: data['senderId'] ?? '',
            text: data['content'] ?? '',
            messageType: 'text',
            isDeleted: false,
            isRead: true,
            currentDateTime: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
            documents: [],
            className: widget.className,
            subject: widget.subjects,
          )).toList();
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getString('uid') ?? 'guest';
        _currentUserName = prefs.getString('name') ?? 'User';
        _isTeacher = prefs.getString('type') == 'teacher' || prefs.getString('type') == 'admin';
      });
      
      // After loading user data, load messages
      await _loadMessages();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.subjects} (${widget.className})'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              reverse: true, // Display recent messages at the bottom
              itemCount: _chatList.length,
              itemBuilder: (context, index) {
                final message = _chatList[index];
                return BubbleSpecialThree(
                  text: message.text,
                  color: message.senderId == _currentUserId
                      ? const Color(0xFF1B97F3)
                      : Colors.grey[300]!,
                  tail: true,
                  isSender: message.senderId == _currentUserId,
                  textStyle: TextStyle(
                    color: message.senderId == _currentUserId ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ),
          // Message input bar
          MessageBar(
            onSend: (message) => _sendMessage(message),
            actions: [
              InkWell(
                child: const Icon(Icons.add, color: Colors.black, size: 24),
                onTap: () {},
              ),
              const SizedBox(width: 8),
              InkWell(
                child: const Icon(Icons.camera_alt, color: Colors.green, size: 24),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
