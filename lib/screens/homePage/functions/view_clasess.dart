import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/classModel.dart';
import '../../../model/historyModel.dart';
import 'Tab Bar/class_history.dart';
import '../../auth/profile/profile_page.dart';
import 'Tab Bar/teacher_tabBar.dart';

class ClassesPage extends StatefulWidget {
  @override
  _ClassesPageState createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  final CollectionReference _classesCollection = FirebaseFirestore.instance.collection('history');
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  void _showAddClassDialog() {
    String selectedClass = '';
    String subject = '';
    String classLabel = '';

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
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  dropdownColor: Colors.deepPurple,
                  items: ['10A', '10B', '11A', '11B']
                      .map((classValue) => DropdownMenuItem(
                    value: classValue,
                    child: Text(
                      classValue,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Class',
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
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value!;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    subject = value;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedClass.isNotEmpty && subject.isNotEmpty && classLabel.isNotEmpty) {
                          try {
                            String classId = _classesCollection.doc().id;

                            ClassModel newClass = ClassModel(
                              id: classId,
                              classLabel: classLabel,
                              className: '',
                              subject: subject,
                            );

                            await _classesCollection.add(newClass.toMap());
                            Navigator.pop(context);
                          } catch (e) {
                            showErrorDialog('Failed to add class: $e');
                          }
                        } else {
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

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Class"),
          content: const Text("Are you sure you want to delete this class?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                // Delete the class from Firestore
                _classesCollection.doc(docId).delete();
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Classes"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Classes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
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
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('history')
                    .where('userUid', isEqualTo: currentUserUid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading history"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final historyDocs = snapshot.data?.docs ?? [];
                  final Set<String> uniqueClasses = {};
                  final List<HistoryModel> uniqueHistory = [];

                  for (var doc in historyDocs) {
                    final historyData = doc.data() as Map<String, dynamic>;
                    final className = historyData['className'] ?? 'No Class Name';
                    final subject = historyData['subject'] ?? 'No Subject';
                    final uniqueKey = '$className|$subject';

                    if (!uniqueClasses.contains(uniqueKey)) {
                      uniqueClasses.add(uniqueKey);
                      uniqueHistory.add(HistoryModel(
                        history_id: historyData['history_id'],
                        date: DateTime.now(),
                        topic: historyData['topic'] ?? 'No Topic',
                        // lessonPlan: historyData['lessonPlan'] ?? 'No Lesson Plan',
                        // ppt: historyData['ppt'] ?? 'No PPT Link',
                        // handout: historyData['handout'] ?? 'No Handout Link',
                        className: className,
                        subject: subject, userUid: currentUserUid,
                        // context_Builder:  historyData['context_Builder'] ?? 'No context_Builder',
                        // application_inRealLife:  historyData['application_inRealLife']??'No application in Real Life',
                      ));
                    }
                  }

                  uniqueHistory.sort((a, b) {
                    // Split class names into numeric and alphabetic parts
                    final aParts = RegExp(r'(\d+)(\D+)').firstMatch(a.className);
                    final bParts = RegExp(r'(\d+)(\D+)').firstMatch(b.className);

                    // Extract the numeric part (grade) and alphabetic part (section)
                    int gradeA = int.tryParse(aParts?.group(1) ?? '') ?? 0;
                    int gradeB = int.tryParse(bParts?.group(1) ?? '') ?? 0;
                    String sectionA = aParts?.group(2) ?? '';
                    String sectionB = bParts?.group(2) ?? '';

                    // Compare by numeric grade first
                    int gradeComparison = gradeA.compareTo(gradeB);

                    // If grades are equal, compare by section alphabetically
                    if (gradeComparison == 0) {
                      int sectionComparison = sectionA.compareTo(sectionB);

                      // If sections are also equal, compare by subject alphabetically
                      if (sectionComparison == 0) {
                        return a.subject.compareTo(b.subject);
                      }
                      return sectionComparison;
                    }

                    return gradeComparison; // Return comparison by grade
                  });


                  if (uniqueHistory.isEmpty) {
                    return const Center(
                      child: Text(
                        "No history available.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 15,
                      childAspectRatio: 10,
                      mainAxisExtent: 60,
                    ),
                    itemCount: uniqueHistory.length,
                    itemBuilder: (context, index) {
                      final history = uniqueHistory[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => teacherTabBar(
                                subject: history.subject,
                                className: history.className,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                          color: Colors.blue,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Class: ${history.className}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Subject: ${history.subject}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (history.history_id.isNotEmpty) {
                                    _showDeleteConfirmationDialog(history.history_id);
                                  } else {
                                    debugPrint('Invalid history ID for deletion');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
