import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';
import '../../model/historyModel.dart';
import '../../screens/homePage/functions/Tab Bar/class_history.dart';

class TeacherDetailView extends StatelessWidget {
  final Map<String, dynamic> teacherData;
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference _classesCollection = FirebaseFirestore.instance.collection('history');

  TeacherDetailView({Key? key, required this.teacherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${teacherData['name']} Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Name', teacherData['name']),
            const SizedBox(height: 10),
            _buildInfoCard('Email', teacherData['email']),
            const SizedBox(height: 10),
            _buildInfoCard('School ID', teacherData['schoolId']),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Classes:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                ),
                ElevatedButton(
                  onPressed: () => _showAddClassDialog(context),
                  child: Text("Add Class"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Teacher')
                  .doc(teacherData['id'])
                  .snapshots(),
              builder: (context, teacherSnapshot) {
                if (teacherSnapshot.hasError) {
                  return const Center(child: Text("Error loading teacher data"));
                }
                if (teacherSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final teacherData = teacherSnapshot.data?.data() as Map<String, dynamic>?;
                final classList = teacherData?['classList'] ?? [];

                if (classList.isEmpty) {
                  return const Center(child: Text("No classes available."));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('history')
                      .where(FieldPath.documentId, whereIn: classList)
                      .snapshots(),
                  builder: (context, historySnapshot) {
                    if (historySnapshot.hasError) {
                      return const Center(child: Text("Error loading history"));
                    }
                    if (historySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final historyDocs = historySnapshot.data?.docs ?? [];
                    if (historyDocs.isEmpty) {
                      return const Center(child: Text("No history available."));
                    }
                    return Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: scrWidth > 360 ? 5 : 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2,
                        ),
                        itemCount: historyDocs.length,
                        itemBuilder: (context, index) {
                          final historyData = historyDocs[index].data() as Map<String, dynamic>;
                          final className = historyData['className'] ?? 'No Class Name';
                          final subject = historyData['subject'] ?? 'No Subject';
                      
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassHistoryPage(
                                    subject: subject,
                                    classname: className,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Class: $className',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'Subject: $subject',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      final historyId = historyDocs[index].id;
                                      if (historyId.isNotEmpty) {
                                        FirebaseFirestore.instance
                                            .collection('history')
                                            .doc(historyId)
                                            .delete()
                                            .then((_) {
                                          debugPrint('History deleted successfully');
                                        }).catchError((error) {
                                          debugPrint('Error deleting history: $error');
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),



          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.deepPurple[50],
      elevation: 5,
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    String selectedClass = '';
    String subject = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add Class",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: _inputDecoration('Class Name'),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) => selectedClass = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: _inputDecoration('Subject'),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) => subject = value,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _addClass(context, selectedClass, subject),
                      child: const Text("Add", style: TextStyle(color: Colors.purple)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Colors.purple)),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white24,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }
  Future<void> _addClass(BuildContext context, String selectedClass, String subject) async {
    if (selectedClass.isEmpty || subject.isEmpty) {
      _showErrorDialog(context, 'Please fill in all fields.');
      return;
    }

    try {
      final querySnapshot = await _classesCollection
          .where('className', isEqualTo: selectedClass)
          .where('subject', isEqualTo: subject)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _showErrorDialog(context, 'This class with the same subject already exists!');
      } else {
        String historyId = _classesCollection.doc().id;

        // Create a new history model instance
        HistoryModel newHistory = HistoryModel(
          history_id: historyId,
          date: DateTime.now(),
          topic: '', // Add appropriate topic if needed
          className: selectedClass,
          subject: subject,
          userUid: teacherData['id'], // Use the ID from teacherData
        );

        // Add the class to the Classes collection
        await _classesCollection.doc(historyId).set(newHistory.toMap());

        // Update the class list in the Teacher document
        final teacherDoc = FirebaseFirestore.instance.collection('Teacher').doc(teacherData['id']);
        await teacherDoc.update({
          'classList': FieldValue.arrayUnion([historyId]),
        });

        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to add class: $e');
    }
  }




  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message, style: const TextStyle(color: Colors.red)),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        );
      },
    );
  }
}

