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

    return StreamBuilder<QuerySnapshot>(
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
          padding: EdgeInsets.all(16),
          itemCount: studentSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var studentDoc = studentSnapshot.data!.docs[index];
            var studentData = studentDoc.data() as Map<String, dynamic>;

            final classList = List<String>.from(studentData['classList'] ?? []);

            return Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Class History",
                      style: TextStyle(
                       
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: classList.map((classId) {
                        return InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => DraggableScrollableSheet(
                                initialChildSize: 0.7,
                                minChildSize: 0.5,
                                maxChildSize: 0.95,
                                builder: (_, scrollController) => ClassHistoryDetails(
                                  classId: classId,
                                  scrollController: scrollController,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              classId,
                              style: TextStyle(
                      
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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

class ClassHistoryDetails extends StatelessWidget {
  final String classId;
  final ScrollController scrollController;

  const ClassHistoryDetails({
    Key? key,
    required this.classId,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Text(
              'History for Class: $classId',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('history')
                  .where('classId', isEqualTo: classId)
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
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var historyDoc = snapshot.data!.docs[index];
                    var historyData = historyDoc.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          historyData['title'] ?? 'No Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            historyData['details'] ?? 'No Details',
                            style: TextStyle(fontSize: 14),
                          ),
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
    );
  }
}