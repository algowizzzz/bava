import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdminDataUpload extends StatefulWidget {
  const AdminDataUpload({super.key});

  @override
  State<AdminDataUpload> createState() => _AdminDataUploadState();
}

class _AdminDataUploadState extends State<AdminDataUpload> {
  void parseCSV(
      FilePickerResult result,
      List<String> headers,
      Function(Map<String, dynamic>) onDataProcessed,
      ) {
    final bytes = result.files.single.bytes;
    final csvData = String.fromCharCodes(bytes!);
    final rows = CsvToListConverter().convert(csvData);

    if (rows.isEmpty || rows.first.length != headers.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid CSV format!')),
      );
      return;
    }

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final data = <String, dynamic>{};
      for (int j = 0; j < headers.length; j++) {
        data[headers[j]] = row[j];
      }
      print("Row ${i}: ${jsonEncode(data)}");
      onDataProcessed(data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File processed successfully!')),
    );
  }
  Future<void> handleFileUpload(
      List<String> headers,
      Function(Map<String, dynamic>) processRow,
      ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      parseCSV(result, headers, processRow);
    }
  }
  void processStudentRow(Map<String, dynamic> data) {
    try {
      final student = StudentModel.fromMap(data);
      debugPrint('Student Data: ${jsonEncode(student.toMap())}');
    } catch (e) {
      debugPrint('Error processing student row: $e');
    }
  }
  void processTeacherRow(Map<String, dynamic> data) {
    try {
      final teacher = TeacherModel.fromMap(data);
      debugPrint('Teacher Data: ${jsonEncode(teacher.toMap())}');
    } catch (e) {
      debugPrint('Error processing teacher row: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Data Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => handleFileUpload(
                StudentModel.headers,
                processStudentRow,
              ),
              child: const Text('Upload Student Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => handleFileUpload(
                TeacherModel.headers,
                processTeacherRow,
              ),
              child: const Text('Upload Teacher Data'),
            ),
          ],
        ),
      ),
    );
  }
}
class StudentModel {
  final String name;
  final String password;
  final String email;
  final int age;
  final String schoolName;
  final String className;
  final String? subject1;
  final String? subject2;
  final String? subject3;
  final String? subject4;
  final String? subject5;
  final String? subject6;
  final String? subject7;
  final String address;
  final String parentContactNo;

  StudentModel({
    required this.name,
    required this.password,
    required this.email,
    required this.age,
    required this.schoolName,
    required this.className,
    this.subject1,
    this.subject2,
    this.subject3,
    this.subject4,
    this.subject5,
    this.subject6,
    this.subject7,
    required this.address,
    required this.parentContactNo,
  });

  static List<String> get headers => [
    'name',
    'password',
    'email',
    'age',
    'schoolName',
    'className',
    'subject1',
    'subject2',
    'subject3',
    'subject4',
    'subject5',
    'subject6',
    'subject7',
    'address',
    'parentContactNo',
  ];

  factory StudentModel.fromMap(Map<String, dynamic> data) {
    return StudentModel(
      name: data['name'],
      password: data['password'],
      email: data['email'],
      age: int.parse(data['age'].toString()),
      schoolName: data['schoolName'],
      className: data['className'],
      subject1: data['subject1'],
      subject2: data['subject2'],
      subject3: data['subject3'],
      subject4: data['subject4'],
      subject5: data['subject5'],
      subject6: data['subject6'],
      subject7: data['subject7'],
      address: data['address'],
      parentContactNo: data['parentContactNo'].toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'password': password,
    'email': email,
    'age': age,
    'schoolName': schoolName,
    'className': className,
    'subject1': subject1,
    'subject2': subject2,
    'subject3': subject3,
    'subject4': subject4,
    'subject5': subject5,
    'subject6': subject6,
    'subject7': subject7,
    'address': address,
    'parentContactNo': parentContactNo,
  };
}

// TeacherModel Class
class TeacherModel {
  final String name;
  final String email;
  final String password;
  final String className1;
  final String subject1;
  final String? className2;
  final String? subject2;
  final String? className3;
  final String? subject3;
  final String? className4;
  final String? subject4;
  final String? className5;
  final String? subject5;
  final String? className6;
  final String? subject6;
  final String? className7;
  final String? subject7;

  TeacherModel({
    required this.name,
    required this.email,
    required this.password,
    required this.className1,
    required this.subject1,
    this.className2,
    this.subject2,
    this.className3,
    this.subject3,
    this.className4,
    this.subject4,
    this.className5,
    this.subject5,
    this.className6,
    this.subject6,
    this.className7,
    this.subject7,
  });

  static List<String> get headers => [
    'name',
    'email',
    'password',
    'className1',
    'subject1',
    'className2',
    'subject2',
    'className3',
    'subject3',
    'className4',
    'subject4',
    'className5',
    'subject5',
    'className6',
    'subject6',
    'className7',
    'subject7',
  ];

  factory TeacherModel.fromMap(Map<String, dynamic> data) {
    return TeacherModel(
      name: data['name'],
      email: data['email'],
      password: data['password'],
      className1: data['className1'],
      subject1: data['subject1'],
      className2: data['className2'],
      subject2: data['subject2'],
      className3: data['className3'],
      subject3: data['subject3'],
      className4: data['className4'],
      subject4: data['subject4'],
      className5: data['className5'],
      subject5: data['subject5'],
      className6: data['className6'],
      subject6: data['subject6'],
      className7: data['className7'],
      subject7: data['subject7'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'password': password,
    'className1': className1,
    'subject1': subject1,
    'className2': className2,
    'subject2': subject2,
    'className3': className3,
    'subject3': subject3,
    'className4': className4,
    'subject4': subject4,
    'className5': className5,
    'subject5': subject5,
    'className6': className6,
    'subject6': subject6,
    'className7': className7,
    'subject7': subject7,
  };
}
