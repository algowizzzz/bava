import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String senderId;
  final String text;
  final String messageType;
  final bool isDeleted;
  final bool isRead;
  final DateTime currentDateTime;
  final List<dynamic> documents;
  final String className;
  final String subject;

  ChatModel({
    required this.senderId,
    required this.text,
    required this.messageType,
    required this.isDeleted,
    required this.isRead,
    required this.currentDateTime,
    required this.documents,
    required this.className,
    required this.subject,
  });

  // fromFirestore constructor to convert Firestore data into a ChatModel instance
  factory ChatModel.fromFirestore(Map<String, dynamic> data) {
    return ChatModel(
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      messageType: data['messageType'] ?? '',
      isDeleted: data['isDeleted'] ?? false,
      isRead: data['isRead'] ?? false,
      currentDateTime: (data['currentDateTime'] as Timestamp).toDate(),
      documents: List.from(data['documents'] ?? []),
      className: data['className'] ?? '',
      subject: data['subject'] ?? '',
    );
  }

  // toFirestore method to convert ChatModel instance back to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'messageType': messageType,
      'isDeleted': isDeleted,
      'isRead': isRead,
      'currentDateTime': Timestamp.fromDate(currentDateTime),
      'documents': documents,
      'className': className,
      'subject': subject,
    };
  }
}
