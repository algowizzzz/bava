import 'package:chatbot/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/historyModel.dart';

class TeacherDetailsPage extends StatefulWidget {
  final String teacherId;

  const TeacherDetailsPage({required this.teacherId, Key? key}) : super(key: key);

  @override
  _TeacherDetailsPageState createState() => _TeacherDetailsPageState();
}

class _TeacherDetailsPageState extends State<TeacherDetailsPage> {
  final CollectionReference _classesCollection =
  FirebaseFirestore.instance.collection('history');
  final _formKey = GlobalKey<FormState>();
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = true;
  bool isEditing = false;

  String name = '';
  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    _fetchTeacherDetails();
  }
  void _showAddClassDialog() {
    String selectedClass = ''; // Default value for class name
    String subject = '';       // Default value for subject

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade900,
                  Colors.purple.shade600,
                  Colors.purpleAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add Class",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Class Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    selectedClass = value; // Update selectedClass
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    subject = value; // Update subject
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Validation for empty fields
                        if (selectedClass.isNotEmpty && subject.isNotEmpty) {
                          try {
                            // Check if class and subject already exist in the 'history' collection
                            final querySnapshot = await FirebaseFirestore.instance
                                .collection('history')
                                .where('className', isEqualTo: selectedClass)
                                .where('userUid', isEqualTo: currentUserUid)
                                .where('subject', isEqualTo: subject)
                                .get();

                            if (querySnapshot.docs.isNotEmpty) {
                              // Show error if duplicate class and subject exist
                              showErrorDialog('This class with the same subject already exists!');
                            } else {
                              // Generate unique ID for history
                              String historyId = FirebaseFirestore.instance.collection('history').doc().id;

                              // Create a HistoryModel instance
                              HistoryModel historyEntry = HistoryModel(
                                history_id: historyId,
                                date: DateTime.now(),
                                topic: '',
                                className: selectedClass,
                                subject: subject,
                                userUid: widget.teacherId,
                              );

                              // Add the history entry to the 'history' collection
                              await FirebaseFirestore.instance.collection('history').doc(historyId).set(historyEntry.toMap());

                              // Update the teacher's document with the new class ID
                              final teacherDoc = FirebaseFirestore.instance.collection('Teacher').doc(widget.teacherId);

                              // Fetch current class list
                              var teacherData = await teacherDoc.get();
                              List<dynamic> classList = teacherData.exists && teacherData.data()?['classList'] != null
                                  ? List.from(teacherData.data()!['classList'])
                                  : [];

                              // Add the new class ID to the list if it's not already there
                              if (!classList.contains(historyId)) {
                                classList.add(historyId);
                              }

                              // Update teacher's class list
                              await teacherDoc.update({'classList': classList});

                              // Fetch students enrolled in this class
                              final studentQuerySnapshot = await FirebaseFirestore.instance
                                  .collection('students')
                                  .where('class', isEqualTo: selectedClass)
                                  .get();

                              // Loop through the students and update their documents with the new historyId
                              for (var studentDoc in studentQuerySnapshot.docs) {
                                String studentId = studentDoc.id;

                                var studentData = studentDoc.data();
                                List<dynamic> studentClassList = List.from(studentData['classList'] ?? []);

                                // Add the new historyId to the student's class list if not already present
                                if (!studentClassList.contains(historyId)) {
                                  studentClassList.add(historyId);
                                }

                                // Update the student's class list
                                await FirebaseFirestore.instance.collection('students').doc(studentId).update({
                                  'classList': studentClassList,
                                });
                              }

                              // Close the dialog after the class is added successfully
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            // Show error if something goes wrong
                            showErrorDialog('Failed to add class: $e');
                          }
                        } else {
                          // Show error if fields are empty
                          showErrorDialog('Please fill in all fields.');
                        }
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),


                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message, style: const TextStyle(color: Colors.red)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _fetchTeacherDetails() async {
    try {
      var teacherDoc = await FirebaseFirestore.instance
          .collection('Teacher')
          .doc(widget.teacherId)
          .get();

      if (teacherDoc.exists) {
        setState(() {
          name = teacherDoc.data()?['name'] ?? '';
          email = teacherDoc.data()?['email'] ?? '';
          password = teacherDoc.data()?['password'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog("Teacher not found.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Failed to load teacher details.");
    }
  }

  void _saveTeacherDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('Teacher')
            .doc(widget.teacherId)
            .update({
          'name': name,
          'email': email,
          'password': password,
        });

        setState(() {
          isEditing = false;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Details updated successfully!")),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog("Failed to save details.");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Details"),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (!isLoading && !isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: isEditing ? _buildEditForm() : _buildDetailsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView() {
    return Center(
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: scrWidth*0.05,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Profile Details",style: TextStyle(
                    fontSize: scrWidth*0.015,
                    color: Colors.purple,
                    fontWeight: FontWeight.w500
                  ),),
                  ElevatedButton(
                    child: const Text("Add Class"),
                    onPressed: _showAddClassDialog,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailItem("Name", name, Icons.person),
              const SizedBox(height: 16),
              _buildDetailItem("Email", email, Icons.email),
              const SizedBox(height: 16),
              _buildDetailItem("Password", password, Icons.lock),
              const SizedBox(height: 16),

              // Stream to display the teacher's classes
              _buildClassStream(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : "Not available",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Teacher Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildEnhancedTextField(
                label: "Name",
                icon: Icons.person,
                hint: "Enter teacher's name",
                initialValue: name,
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              _buildEnhancedTextField(
                label: "Email",
                icon: Icons.email,
                hint: "Enter teacher's email",
                initialValue: email,
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 16),
              _buildEnhancedTextField(
                label: "Password",
                icon: Icons.lock,
                hint: "Enter a secure password",
                initialValue: password,
                obscureText: true,
                onChanged: (value) => password = value,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _saveTeacherDetails,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Cancel", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required String label,
    required IconData icon,
    required String hint,
    required String initialValue,
    bool obscureText = false,
    required ValueChanged<String> onChanged,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.deepPurple),
            border: InputBorder.none,
          ),
          obscureText: obscureText,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "$label cannot be empty.";
            }
            return null;
          },
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Stream to show teacher's classes
  Widget _buildClassStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('history')
          .where('userUid', isEqualTo: widget.teacherId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No classes available.");
        }

        final classes = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Classes ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
            ),
            const SizedBox(height: 8),
            ...classes.map((doc) {
              final className = doc['className'] ?? 'Class name not available';
              final subject = doc['subject'] ?? 'Subject not available';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '$className - $subject', // Display class name and subject
                  style: const TextStyle(fontSize: 16,color: Colors.black),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
