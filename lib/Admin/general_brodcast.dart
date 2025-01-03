// import 'package:flutter/material.dart';
// import 'package:chat_bubbles/chat_bubbles.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../../../model/chatModel.dart';
//
// class ChatPage extends StatefulWidget {
//
//   const ChatPage({Key? key,}) : super(key: key);
//
//   @override
//   _ChatPageState createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
//   List<ChatModel> _chatList = [];
//
//   // Function to send a message to Firebase Firestore
//   void _sendMessage(String text) async {
//     if (text.trim().isEmpty) return;
//
//     final newMessage = ChatModel(
//       senderId: _currentUserId,
//       text: text,
//       messageType: 'text',
//       isDeleted: false,
//       isRead: false,
//       currentDateTime: DateTime.now(),
//       documents: [],
//       className:'',
//       subject: '',
//     );
//
//     final chatDocRef = _firestore.collection('chats').doc('chatSession');
//
//     // Use a transaction to avoid overwriting the messages
//     await _firestore.runTransaction((transaction) async {
//       final docSnapshot = await transaction.get(chatDocRef);
//       if (docSnapshot.exists) {
//         List<Map<String, dynamic>> messages = List<Map<String, dynamic>>.from(docSnapshot['messages'] ?? []);
//         // Ensure we only insert the new message
//         messages.insert(0, newMessage.toFirestore());
//         transaction.update(chatDocRef, {'messages': messages, 'updatedAt': Timestamp.now()});
//       } else {
//         await chatDocRef.set({
//           'messages': [newMessage.toFirestore()],
//           'createdAt': Timestamp.now(),
//           'updatedAt': Timestamp.now(),
//           'className': '',
//           'subject': '',
//         });
//       }
//     });
//
//     setState(() {
//       _chatList.insert(0, newMessage);
//     });
//   }
//   void _streamMessages() {
//     final chatDocRef = _firestore.collection('chats').doc('chatSession');
//     chatDocRef.snapshots().listen((docSnapshot) {
//       if (docSnapshot.exists) {
//         List<Map<String, dynamic>> messages = List<Map<String, dynamic>>.from(docSnapshot['messages'] ?? []);
//
//         final filteredMessages = messages.where((data) {
//           return data['className'] == widget.className && data['subject'] == widget.subjects;
//         }).toList();
//
//         setState(() {
//           _chatList = filteredMessages.map((data) => ChatModel.fromFirestore(data)).toList();
//         });
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _streamMessages();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.subjects} (${widget.className})'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//               reverse: true, // Display recent messages at the bottom
//               itemCount: _chatList.length,
//               itemBuilder: (context, index) {
//                 final message = _chatList[index];
//                 return BubbleSpecialThree(
//                   text: message.text,
//                   color: message.senderId == _currentUserId
//                       ? const Color(0xFF1B97F3)
//                       : Colors.grey[300]!,
//                   tail: true,
//                   isSender: message.senderId == _currentUserId,
//                   textStyle: TextStyle(
//                     color: message.senderId == _currentUserId ? Colors.white : Colors.black,
//                     fontSize: 16,
//                   ),
//                 );
//               },
//             ),
//           ),
//           // Message input bar
//           MessageBar(
//             onSend: (message) => _sendMessage(message),
//             actions: [
//               InkWell(
//                 child: const Icon(Icons.add, color: Colors.black, size: 24),
//                 onTap: () {},
//               ),
//               const SizedBox(width: 8),
//               InkWell(
//                 child: const Icon(Icons.camera_alt, color: Colors.green, size: 24),
//                 onTap: () {},
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
