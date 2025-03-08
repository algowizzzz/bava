import 'package:intl/intl.dart';

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

  // fromJson constructor to convert MongoDB API data into a ChatModel instance
  factory ChatModel.fromJson(Map<String, dynamic> data) {
    return ChatModel(
      senderId: data['senderId'] ?? '',
      text: data['content'] ?? data['text'] ?? '',
      messageType: data['messageType'] ?? 'text',
      isDeleted: data['isDeleted'] ?? false,
      isRead: data['isRead'] ?? true,
      currentDateTime: data['timestamp'] != null 
          ? DateTime.parse(data['timestamp']) 
          : (data['currentDateTime'] != null 
              ? DateTime.parse(data['currentDateTime']) 
              : DateTime.now()),
      documents: List.from(data['documents'] ?? []),
      className: data['className'] ?? '',
      subject: data['subject'] ?? '',
    );
  }

  // toJson method to convert ChatModel instance to JSON for MongoDB API
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': text,
      'messageType': messageType,
      'isDeleted': isDeleted,
      'isRead': isRead,
      'timestamp': currentDateTime.toIso8601String(),
      'documents': documents,
      'className': className,
      'subject': subject,
    };
  }
  
  // For backward compatibility
  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}
