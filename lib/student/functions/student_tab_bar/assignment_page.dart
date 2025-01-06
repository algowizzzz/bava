import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StudentAssignmentPage extends StatefulWidget {
  final String studentId;

  const StudentAssignmentPage({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentAssignmentPageState createState() => _StudentAssignmentPageState();
}

class _StudentAssignmentPageState extends State<StudentAssignmentPage> {
  PlatformFile? _selectedFile;
  bool _isAssignmentSubmitted = false;

  Future<void> _trackDownload(String assignmentId) async {
    try {
      final assignmentRef = FirebaseFirestore.instance.collection('assignments').doc(assignmentId);
      await assignmentRef.update({'downloads.${widget.studentId}': true});
      print("Download tracked successfully for student: ${widget.studentId}");
    } catch (e) {
      print("Error tracking download: $e");
    }
  }

  Future<void> _downloadFile(String fileUrl, String assignmentId) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
      await _trackDownload(assignmentId);
    } else {
      print("Could not launch file URL");
    }
  }

  Future<void> _uploadCompletedAssignment(String assignmentId) async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a file to upload.")));
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('completed_assignments/$assignmentId/${widget.studentId}_${_selectedFile!.name}');
      final uploadTask = storageRef.putData(_selectedFile!.bytes!);
      final taskSnapshot = await uploadTask.whenComplete(() => null);
      final uploadedFileUrl = await taskSnapshot.ref.getDownloadURL();

      // Log the URL to check if it's correct
      print("File uploaded successfully! URL: $uploadedFileUrl");

      final assignmentRef = FirebaseFirestore.instance.collection('assignments').doc(assignmentId);
      await assignmentRef.update({'submissions.${widget.studentId}': uploadedFileUrl});

      setState(() { _isAssignmentSubmitted = true; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assignment submitted successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error uploading assignment: $e")));
    }
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result != null) {
      setState(() { _selectedFile = result.files.first; });
    } else {
      print("No file selected");
    }
  }

  Future<void> _viewFile(String fileUrl) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
    } else {
      print("Could not open file");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Assignments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('assignments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No assignments available."));
          }

          final assignments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final data = assignments[index].data() as Map<String, dynamic>;
              final assignmentId = assignments[index].id;
              final fileName = data['fileName'] as String? ?? 'Unknown Assignment';
              final fileUrl = data['fileUrl'] as String? ?? '';
              final message = data['message'] as String? ?? 'No additional details.';
              final submission = data['submissions']?[widget.studentId];
              String? submittedFileName;
              String? submittedFileUrl;

              if (submission is String) {
                submittedFileName = "Submitted File";
                submittedFileUrl = submission;
              } else if (submission is String?) {
                submittedFileName = "Submitted File";
                submittedFileUrl = submission;
              }

              final submissionStatus = submittedFileUrl != null;

              // Print all details for the current assignment
              print("Assignment ID: $assignmentId");
              print("File Name: $fileName");
              print("File URL: $fileUrl");
              print("Message: $message");
              print("Student's Submitted File URL: $submittedFileUrl");
              print("Submission Status: $submissionStatus");

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Assignment: $fileName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 10),
                      Text("Message: $message", style: const TextStyle(color: Colors.black)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _downloadFile(fileUrl, assignmentId),
                        child: const Text("Download Assignment"),
                      ),
                      const SizedBox(height: 20),
                      Text("Submit Completed Assignment", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 10),
                        Text("Selected File: ${_selectedFile!.name}", style: const TextStyle(color: Colors.black)),
                      ],
                      if (!submissionStatus) ...[
                        ElevatedButton(
                          onPressed: _selectFile,
                          child: const Text("Select File"),
                        ),
                      ],
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: submissionStatus ? null : () => _uploadCompletedAssignment(assignmentId),
                        child: Text(submissionStatus ? "Assignment Submitted" : "Submit Assignment"),
                      ),
                      if (submittedFileUrl != null) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _viewFile(submittedFileUrl!),
                          child: const Text("View Submitted File"),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
