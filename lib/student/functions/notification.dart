import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDisplay extends StatefulWidget {
  const NotificationDisplay({Key? key}) : super(key: key);

  @override
  _NotificationDisplayState createState() => _NotificationDisplayState();
}

class _NotificationDisplayState extends State<NotificationDisplay> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  List<Map<String, dynamic>> _chatList = [];

  @override
  void initState() {
    super.initState();
    _streamMessages();
  }

  void _streamMessages() {
    _firestore
        .collection('chats')
        .doc('Admin broadcast')
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists && mounted) {
        setState(() {
          _chatList = List<Map<String, dynamic>>.from(
              docSnapshot['messages'] ?? []);
        });
      }
    });
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Time';
    return DateFormat('HH:mm').format(timestamp.toDate());
  }

  Widget _buildMessageCard(Map<String, dynamic> messageData) {
    final message = messageData['text'] ?? '';
    final timestamp = messageData['currentDateTime'] as Timestamp?;
    final senderId = messageData['senderId'] ?? 'unknown';
    final isSender = senderId == _currentUserId;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin Notice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  _formatDate(timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(timestamp),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: _chatList.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _chatList.length,
              itemBuilder: (context, index) => _buildMessageCard(_chatList[index]),
            ),
    );
  }
}
