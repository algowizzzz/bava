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
        color: Colors.white,
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
                    Icon(Icons.quiz_outlined, size: 100, color: Colors.grey[400]),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No Quizzes found for ${widget.classname} - ${widget.subject}.',
                        style: const TextStyle(color: Colors.grey, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Error loading data',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            }
        
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var quizData = snapshot.data!.docs[snapshot.data!.docs.length - 1 - index].data() as Map<String, dynamic>;
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
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
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
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        quizData['quizName'] ?? 'Untitled Quiz',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${quizData['noOfQns']} Questions',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Marks: ${quizData['totalMarksQuiz']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (scoreData != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.star, size: 18, color: Colors.amber[700]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Current Score: ${scoreData['currentScore']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.emoji_events, size: 18, color: Colors.blue[700]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Max Score: ${scoreData['maxScore']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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