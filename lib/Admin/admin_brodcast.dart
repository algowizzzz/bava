import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminBoardcast extends StatefulWidget {
  const AdminBoardcast({Key? key}) : super(key: key);

  @override
  _AdminBoardcastState createState() => _AdminBoardcastState();
}

class _AdminBoardcastState extends State<AdminBoardcast> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  List<Map<String, dynamic>> _groupMessages = [];
  List<Map<String, dynamic>> _privateMessages = [];

  // Controller for managing tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _streamGroupMessages();
    _streamPrivateMessages();
  }

  void _streamGroupMessages() {
    final groupChatRef = _firestore.collection('chats').doc('Admin broadcast');
    groupChatRef.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          _groupMessages =
          List<Map<String, dynamic>>.from(docSnapshot['messages'] ?? []);
        });
      }
    });
  }

  void _streamPrivateMessages() {
    final privateChatRef =
    _firestore.collection('private_chats').doc(_currentUserId);
    privateChatRef.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          _privateMessages =
          List<Map<String, dynamic>>.from(docSnapshot['messages'] ?? []);
        });
      }
    });
  }

  void _sendMessage(String text, bool isGroupChat) async {
    if (text.trim().isEmpty) return;

    final newMessage = {
      'senderId': _currentUserId,
      'text': text,
      'messageType': 'text',
      'isDeleted': false,
      'isRead': false,
      'currentDateTime': Timestamp.now(),
    };

    final chatRef = isGroupChat
        ? _firestore.collection('chats').doc('Admin broadcast')
        : _firestore.collection('private_chats').doc(_currentUserId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(chatRef);
      if (docSnapshot.exists) {
        List<Map<String, dynamic>> messages =
        List<Map<String, dynamic>>.from(docSnapshot['messages'] ?? []);
        messages.insert(0, newMessage);
        transaction.update(chatRef, {'messages': messages});
      } else {
        transaction.set(chatRef, {'messages': [newMessage]});
      }
    });
  }

  Widget _buildMessageList(List<Map<String, dynamic>> messages, bool isGroupChat) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return BubbleSpecialThree(
          text: message['text'],
          color: message['senderId'] == _currentUserId
              ? const Color(0xFF1B97F3)
              : Colors.grey[300]!,
          tail: true,
          isSender: message['senderId'] == _currentUserId,
          textStyle: TextStyle(
            color: message['senderId'] == _currentUserId ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(bool isGroupChat) {
    return MessageBar(
      onSend: (message) => _sendMessage(message, isGroupChat),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: 'Group Chat'),
            Tab(icon: Icon(Icons.person), text: 'Private Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Group Chat Section
          Column(
            children: [
              Expanded(child: _buildMessageList(_groupMessages, true)),
              _buildMessageInput(true),
            ],
          ),
          // Private Chat Section
          Column(
            children: [
              Expanded(child: _buildMessageList(_privateMessages, false)),
              _buildMessageInput(false),
            ],
          ),
        ],
      ),
    );
  }
}
