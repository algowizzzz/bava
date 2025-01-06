import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentHistoryPage extends StatefulWidget {
  final String className;
  final String subject;
  final String studentId;
  const StudentHistoryPage({Key? key, required this.className, required this.subject, required this.studentId}) : super(key: key);

  @override
  _StudentHistoryPageState createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  late final CollectionReference studentCollection;

  @override
  void initState() {
    super.initState();
    studentCollection = FirebaseFirestore.instance.collection('students');
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Student History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentCollection
            .where('class', isEqualTo: widget.className)
            .where('subjects', arrayContains: widget.subject)
            .where('id', isEqualTo: widget.studentId)
            .snapshots(),
        builder: (context, studentSnapshot) {
          if (studentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (studentSnapshot.hasError) {
            return const Center(child: Text('Error loading student data'));
          }
          if (!studentSnapshot.hasData || studentSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          return ListView.builder(
            itemCount: studentSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var studentDoc = studentSnapshot.data!.docs[index];
              var studentData = studentDoc.data() as Map<String, dynamic>;

              final classList = List<String>.from(studentData['classList'] ?? []);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Class List: ", style: TextStyle(fontSize: scrWidth * 0.03, color: Colors.black)),
                  Wrap(
                    children: classList.map((classId) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to the history page, passing the classId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryPage(classId: classId),
                            ),
                          );
                        },
                        child: Chip(label: Text(classId)),
                      );
                    }).toList(),
                  ),

                ],
              );
            },
          );
        },
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final String classId;

  const HistoryPage({Key? key, required this.classId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History for Class: $classId')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('history')
            .where('classId', isEqualTo: classId) // Filter by classId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading history data'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No history found for this class.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var historyDoc = snapshot.data!.docs[index];
              var historyData = historyDoc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(historyData['title'] ?? 'No Title'),
                subtitle: Text(historyData['details'] ?? 'No Details'),
              );
            },
          );
        },
      ),
    );
  }
}
