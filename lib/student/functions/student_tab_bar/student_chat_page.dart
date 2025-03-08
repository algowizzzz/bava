import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../services/api_service.dart';

class studentsChatPage extends StatefulWidget {
  final String className;
  final String subjects;

  studentsChatPage({required this.className, required this.subjects});

  @override
  _studentsChatPageState createState() => _studentsChatPageState();
}

class _studentsChatPageState extends State<studentsChatPage> {
  final ApiService _apiService = ApiService();
  String _currentUserId = 'guest';
  String _chatId = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _chatList = [];

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
      });
      
      await _loadMessages();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get student's chats
      final chats = await _apiService.getChatsByStudent(_currentUserId);
      
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
          _chatList = List<Map<String, dynamic>>.from(messages);
          _isLoading = false;
        });
      } else {
        setState(() {
          _chatList = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return 'Unknown Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subjects} - ${widget.className}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMessages,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade50, Colors.white],
            ),
          ),
          child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _chatList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      reverse: false,
                      itemCount: _chatList.length,
                      itemBuilder: (context, index) {
                        final messageData = _chatList[index];
                        final message = messageData['content'] ?? messageData['text'] ?? '';
                        final senderId = messageData['senderId'] ?? 'unknown';
                        final timestamp = messageData['timestamp'] ?? messageData['currentDateTime'];
                        final isSender = senderId == _currentUserId;
                        final formattedDate = timestamp != null
                            ? _formatTimestamp(timestamp)
                            : 'Unknown Time';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSender
                                      ? Colors.deepPurple
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    color:
                                        isSender ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}