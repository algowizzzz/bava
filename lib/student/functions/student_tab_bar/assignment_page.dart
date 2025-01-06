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

      print("File uploaded successfully! URL: $uploadedFileUrl");

      final assignmentRef = FirebaseFirestore.instance.collection('assignments').doc(assignmentId);
      await assignmentRef.update({'submissions.${widget.studentId}': uploadedFileUrl});

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
    return StreamBuilder<QuerySnapshot>(
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
            String? submittedFileUrl;

            if (submission is String) {
              submittedFileUrl = submission;
            } else if (submission is String?) {
              submittedFileUrl = submission;
            }

            final submissionStatus = submittedFileUrl != null;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 16, color: Colors.black54)
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            onPressed: () => _downloadFile(fileUrl, assignmentId),
                            label: const Text("Download"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          "Selected: ${_selectedFile!.name}",
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)
                        ),
                      ),
                    if (!submissionStatus)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.attach_file),
                              onPressed: _selectFile,
                              label: const Text("Select File"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.upload),
                              onPressed: () => _uploadCompletedAssignment(assignmentId),
                              label: const Text("Submit"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (submissionStatus)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _viewFile(submittedFileUrl!),
                        label: const Text("View Submission"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}