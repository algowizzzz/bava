import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class notification extends StatefulWidget {
  const notification({Key? key}) : super(key: key);

  @override
  _notificationState createState() => _notificationState();
}

class _notificationState extends State<notification> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  late List<Map<String, dynamic>> _chatList;

  @override
  void initState() {
    super.initState();
    _chatList = [];
    _streamMessages();
  }

  void _streamMessages() {
    final chatDocRef = _firestore.collection('chats').doc('Admin broadcast');
    chatDocRef.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        List<Map<String, dynamic>> messages =
        List<Map<String, dynamic>>.from(docSnapshot['messages'] ?? []);
        setState(() {
          _chatList = messages;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
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
                final timestamp = messageData['currentDateTime'] as Timestamp?;
                final senderId = messageData['senderId'] ?? 'unknown';
                final isSender = senderId == _currentUserId;

                // Format the timestamp and extract the date and time separately
                final date =
                timestamp != null ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}" : 'Unknown Date';
                final time =
                timestamp != null ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}" : 'Unknown Time';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Message container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSender ? const Color(0xFF1B97F3) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin: Admin name", // Replace with dynamic admin name if needed
                              style: TextStyle(
                                color: isSender ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Notice: $message",
                              style: TextStyle(
                                color: isSender ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Display time at the bottom of the container
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                time,
                                style: TextStyle(
                                  color: isSender ? Colors.white70 : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
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
