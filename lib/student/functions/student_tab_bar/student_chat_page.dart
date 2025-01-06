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
  List<Map<String, dynamic>> _chatList = [];

  @override
  void initState() {
    super.initState();
    _streamMessages();
  }

  void _streamMessages() {
    _firestore
        .collection('chats')
        .doc('chatSession')
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        final messages = List<Map<String, dynamic>>.from(
            docSnapshot['messages'] ?? []);
        final filteredMessages = messages.where((data) =>
            data['className'] == widget.className &&
            data['subject'] == widget.subjects).toList();

        setState(() => _chatList = filteredMessages);
      }
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
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
      body: Container(
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
              child: _chatList.isEmpty
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
                        final message = messageData['text'] ?? '';
                        final senderId = messageData['senderId'] ?? 'unknown';
                        final timestamp =
                            messageData['currentDateTime'] as Timestamp?;
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
    );
  }
}