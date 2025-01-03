import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class studentsChatPage extends StatefulWidget {
  final String className;
  final String subjects;

  studentsChatPage({required this.className, required this.subjects});

  @override
  _studentsChatPageState createState() => _studentsChatPageState();
}

class _studentsChatPageState extends State<studentsChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  late List<Map<String, dynamic>> _chatList; // List to store the filtered messages

  @override
  void initState() {
    super.initState();
    _chatList = []; // Initialize the chat list
    _streamMessages(); // Start streaming messages
  }

  void _streamMessages() {
    final chatDocRef = _firestore.collection('chats').doc('chatSession');
    chatDocRef.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        List<Map<String, dynamic>> messages = List<Map<String, dynamic>>.from(docSnapshot['messages'] ?? []);

        final filteredMessages = messages.where((data) {
          return data['className'] == widget.className && data['subject'] == widget.subjects;
        }).toList();

        setState(() {
          _chatList = filteredMessages; // Update the chat list
        });
      }
    });
  }
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.subjects} (${widget.className})'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatList.isEmpty
                ? Center(child: Text('No messages yet.'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              reverse: false,
              itemCount: _chatList.length,
              itemBuilder: (context, index) {
                final messageData = _chatList[index];
                final message = messageData['text'] ?? '';
                final senderId = messageData['senderId'] ?? 'unknown';
                final timestamp = messageData['currentDateTime'] as Timestamp?;
                final isSender = senderId == _currentUserId;
                final formattedDate =
                timestamp != null ? _formatTimestamp(timestamp) : 'Unknown Time';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    crossAxisAlignment:
                    isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSender ? const Color(0xFF1B97F3) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isSender ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
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
    );
  }
}
