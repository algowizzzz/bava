import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final bool isAdmin;
  final String schoolId;
  final List<String> classList;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.isAdmin,
    required this.schoolId,
    required this.classList,
  });

  // Factory constructor to create a TeacherModel from Firestore DocumentSnapshot
  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TeacherModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      schoolId: data['schoolId'] ?? '',
      classList: List<String>.from(data['classList'] ?? []),
    );
  }

  // Convert TeacherModel to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'isAdmin': isAdmin,
      'schoolId': schoolId,
      'classList': classList,
    };
  }
}
