import 'package:chatbot/student/show_question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentQuizzList extends StatefulWidget {
  final String classname;
  final String subject;
  final String studentId;
  const StudentQuizzList({
    super.key,
    required this.classname,
    required this.subject,
    required this.studentId,
  });  

  @override
  State<StudentQuizzList> createState() => _StudentQuizzListState();
}

class _StudentQuizzListState extends State<StudentQuizzList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>?> getStudentQuizScore(String quizId) async {
    try {
      DocumentSnapshot scoreDoc = await _firestore
          .collection('students')
          .doc(widget.studentId)
          .collection('quizzes')
          .doc(quizId)
          .get();
      
      if (scoreDoc.exists) {
        return scoreDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('quizzes')
              .where('class', isEqualTo: widget.classname)
              .where('subjects', isEqualTo: widget.subject)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      'No Quizzes found for ${widget.classname} - ${widget.subject}.',
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error loading data', style: TextStyle(color: Colors.red, fontSize: 16)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var quizData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('students')
                      .doc(widget.studentId)
                      .collection('quizzes')
                      .doc(quizData['quizId'])
                      .snapshots(),
                  builder: (context, scoreSnapshot) {
                    Map<String, dynamic>? scoreData;
                    if (scoreSnapshot.hasData && scoreSnapshot.data!.exists) {
                      scoreData = scoreSnapshot.data!.data() as Map<String, dynamic>;
                    }
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quizData['quizName'] ?? 'Untitled Quiz',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total Marks: ${quizData['totalMarksQuiz']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            if (scoreData != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Score: ${scoreData['currentScore']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Max Score: ${scoreData['maxScore']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.blue,
                                    ),
                                  ),
                               
                                ],
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${quizData['noOfQns']} Questions',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowQuestion(
                                quizzId: quizData['quizId'],
                                studentId: widget.studentId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                );
              },
            );
          },
        ),
      ),
    );
  }
}