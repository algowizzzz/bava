import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentUploadPage extends StatefulWidget {
  final String classname;
  final String subject;
  const AssignmentUploadPage({Key? key, required this.classname, required this.subject}) : super(key: key);

  @override
  _AssignmentUploadPageState createState() => _AssignmentUploadPageState();
}

class _AssignmentUploadPageState extends State<AssignmentUploadPage> {
  PlatformFile? _selectedFile;
  final TextEditingController _messageController = TextEditingController();
  bool _submitOnline = false;

  // Function to select a file
  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'], // Allowed file types
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  // Function to upload file to Firebase Storage
  Future<String?> _uploadFileToFirebase(String fileName, Uint8List fileBytes) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('assignments/$fileName');
      final uploadTask = storageRef.putData(fileBytes);
      final taskSnapshot = await uploadTask.whenComplete(() => null);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _saveAssignment() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a message.")),
      );
      return;
    }

    try {
      String? uploadedFileUrl;
      String? fileName = _selectedFile?.name ?? ''; // Added to store file name
      if (_selectedFile != null && _selectedFile!.bytes != null) {
        uploadedFileUrl = await _uploadFileToFirebase(
          fileName,
          _selectedFile!.bytes!,
        );
      }

      // Save to Firestore with the file name
      await FirebaseFirestore.instance.collection('assignments').add({
        'fileUrl': uploadedFileUrl ?? '',
        'fileName': fileName, // Save the file name here
        'uploadTime': Timestamp.now(),
        'message': _messageController.text,
        'submitOnline': _submitOnline,
        'downloads': {},
      });

      setState(() {
        _selectedFile = null;
        _messageController.clear();
        _submitOnline = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading assignment: $e")),
      );
    }
  }

  // Function to show the upload form
  void _showUploadForm() {
    bool localSubmitOnline = _submitOnline; // Local copy of the state variable
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) { // Use StatefulBuilder for dialog state management
            return AlertDialog(
              title: const Text("Upload Assignment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message input field with improved styling
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: "Message",
                        hintText: "Enter assignment details or instructions",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Checkbox for online submission with improved design
                    Row(
                      children: [
                        Checkbox(
                          side: const BorderSide(color: Colors.blue),
                          value: localSubmitOnline,
                          onChanged: (value) {
                            setDialogState(() { // Update dialog-specific state
                              localSubmitOnline = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          "Submit online?",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // File upload button with a custom style
                    ElevatedButton.icon(
                      onPressed: _selectFile,
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text("Select File", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    if (_selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Selected File: ${_selectedFile!.name}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _submitOnline = localSubmitOnline; // Update the main state variable
                    await _saveAssignment(); // Save assignment details
                    Navigator.of(context).pop(); // Close dialog after upload
                  },
                  child: const Text("Upload", style: TextStyle(fontSize: 16,color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Navigate to download status page
  void _viewDownloadStatus(String assignmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentDownloadStatusPage(assignmentId: assignmentId, studentId: '',),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('assignments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No assignments uploaded yet."));
          }

          final assignments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final doc = assignments[index];
              final data = doc.data() as Map<String, dynamic>;
              final message = data['message'] ?? '';
              final fileName = data['fileName'] ?? ''; // Retrieve the file name
              final uploadTime = (data['uploadTime'] as Timestamp).toDate();
              final formattedTime = "${uploadTime.toLocal()}".split(' ')[0];

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text("Uploaded on: $formattedTime\nFile: $fileName"), // Display file name here
                  trailing: GestureDetector(
                    onTap: () {
                      _viewDownloadStatus(doc.id);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.download, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          "Download Status",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadForm,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}



class AssignmentDownloadStatusPage extends StatefulWidget {
  final String assignmentId;
  final String studentId;

  const AssignmentDownloadStatusPage({Key? key, required this.assignmentId, required this.studentId})
      : super(key: key);

  @override
  _AssignmentDownloadStatusPageState createState() =>
      _AssignmentDownloadStatusPageState();
}

class _AssignmentDownloadStatusPageState
    extends State<AssignmentDownloadStatusPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> studentDetails = {};
  bool isFileSelected = false;
  var _selectedFile;
  bool _isAssignmentSubmitted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStudentDetails();
  }

  // Track assignment download
  Future<void> _trackDownload(String assignmentId) async {
    try {
      final assignmentRef = FirebaseFirestore.instance.collection('assignments').doc(assignmentId);

      await assignmentRef.update({
        'downloads.${widget.studentId}': true,
      });

      print("Download tracked successfully for student:");
    } catch (e) {
      print("Error tracking download: $e");
    }
  }

  // Download file
  Future<void> _downloadFile(String fileUrl, String assignmentId) async {
    final Uri url = Uri.parse(fileUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);

      // Track the download after successfully launching the file URL
      await _trackDownload(assignmentId);
    } else {
      print("Could not launch file URL");
    }
  }

  // Upload completed assignment
  Future<void> _uploadCompletedAssignment(String assignmentId) async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file to upload.")),
      );
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('completed_assignments/$assignmentId/${widget.studentId}_${_selectedFile!.name}');
      final uploadTask = storageRef.putData(_selectedFile!.bytes!);
      final taskSnapshot = await uploadTask.whenComplete(() => null);

      // Get the uploaded file URL
      final uploadedFileUrl = await taskSnapshot.ref.getDownloadURL();

      // Update Firestore with the uploaded file details
      final assignmentRef = FirebaseFirestore.instance.collection('assignments').doc(assignmentId);
      await assignmentRef.update({
        'submissions.${widget.studentId}': uploadedFileUrl,
      });

      setState(() {
        _isAssignmentSubmitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading assignment: $e")),
      );
    }
  }

  // Fetch student details
  Future<void> _fetchStudentDetails() async {
    try {
      final studentSnapshot =
      await FirebaseFirestore.instance.collection('students').get();
      final details = {
        for (var doc in studentSnapshot.docs) doc.id: doc.data()
      };
      setState(() {
        studentDetails = details;
      });
    } catch (e) {
      print("Error fetching student details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Download & Submission Status"),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Downloads"),
            Tab(text: "Submissions"),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.white,
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('assignments')
            .doc(widget.assignmentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Assignment not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final downloads = data['downloads'] as Map<String, dynamic>? ?? {};
          final submissions = data['submissions'] as Map<String, dynamic>? ?? {};

          return TabBarView(
            controller: _tabController,
            children: [
              _buildStatusList(
                statusMap: downloads,
                title: "Downloads",
                emptyMessage: "No students have downloaded this assignment yet.",
              ),
              _buildStatusList(
                statusMap: submissions,
                title: "Submissions",
                emptyMessage: "No students have submitted this assignment yet.",
                isSubmission: true,  // Mark this tab as submissions
              ),
            ],
          );
        },
      ),
    );
  }

  // Build the status list for downloads or submissions
  Widget _buildStatusList({
    required Map<String, dynamic> statusMap,
    required String title,
    required String emptyMessage,
    bool isSubmission = false,
  }) {
    if (statusMap.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      itemCount: statusMap.keys.length,
      itemBuilder: (context, index) {
        final studentId = statusMap.keys.elementAt(index);
        final status = statusMap[studentId] == true;
        final studentData = studentDetails[studentId] ?? {};

        final studentName = studentData['name'] ?? 'Unknown Student';
        final studentClass = studentData['class'] ?? 'Unknown Class';
        final studentEmail = studentData['email'] ?? 'Unknown Email';
        final submissionFileUrl = studentData['submissionFileUrl']; // Get the file URL for submission

        // Determine the button label based on download/submission status
        String buttonLabel;
        if (isSubmission) {
          // For submissions
          buttonLabel = submissionFileUrl != null ? 'Submitted' : 'Submission Pending';
        } else {
          // For downloads
          buttonLabel = status ? 'Downloaded' : 'Pending';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListTile(
            title: Text(
              "Student: $studentName",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Class: $studentClass"),
                Text("Email: $studentEmail"),
                if (isSubmission && submissionFileUrl != null)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Text("Submitted Assignment:"),
                      ElevatedButton(
                        onPressed: () => _downloadFile(submissionFileUrl, widget.assignmentId),
                        child: const Text("Download Submitted File"),
                      ),
                      ElevatedButton(
                        onPressed: () => _viewFile(submissionFileUrl),
                        child: const Text("View Submitted File"),
                      ),
                    ],
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _toggleStatus(statusMap, studentId, title),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: status ? Colors.green : Colors.red,
                  ),
                  child: Text(buttonLabel), // Display the appropriate status
                ),
                IconButton(
                  onPressed: () => _sendReminder(studentEmail),
                  icon: const Icon(Icons.mail, color: Colors.blue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Toggle download/submission status
  Future<void> _toggleStatus(
      Map<String, dynamic> statusMap,
      String studentId,
      String title,
      ) async {
    final updatedStatus = !statusMap[studentId];
    final fieldName = title == "Downloads" ? "downloads" : "submissions";

    try {
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignmentId)
          .update({
        '$fieldName.$studentId': updatedStatus,
      });

      setState(() {
        statusMap[studentId] = updatedStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${title.substring(0, title.length - 1)} status updated successfully."),
      ));
    } catch (e) {
      print("Error updating status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status.")),
      );
    }
  }

  // Send reminder to student
  void _sendReminder(String email) {
    if (email.isEmpty || email == 'Unknown Email') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not available.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Reminder sent to $email."),
    ));
    // Add logic for sending email reminder if needed
  }

  // View the submitted file
  Future<void> _viewFile(String fileUrl) async {
    final Uri url = Uri.parse(fileUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url); // Launch the file URL
    } else {
      print("Could not view file");
    }
  }
}

