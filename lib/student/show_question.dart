    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:flutter/material.dart';

    class ShowQuestion extends StatefulWidget {
      final String quizzId;
      final String studentId;
      const ShowQuestion({Key? key, required this.quizzId, required this.studentId}) : super(key: key);

      @override
      State<ShowQuestion> createState() => _ShowQuestionState();
    }

    class _ShowQuestionState extends State<ShowQuestion> {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      Map<String, String> selectedAnswers = {};
      double totalScore = 0;
      bool showResults = false;

      Future<void> _saveScore(double score) async {
        DocumentReference studentRef = _firestore
            .collection('students')
            .doc(widget.studentId)
            .collection('quizzes')
            .doc(widget.quizzId);
        DocumentSnapshot studentDoc = await studentRef.get();

        if (studentDoc.exists) {
          Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;
          double maxScore = data['maxScore'] ?? 0.0;
          if (score > maxScore) {
            await studentRef.update({
              'currentScore': score,
              'maxScore': score,
              'lastAttempt': DateTime.now(),
            });
          } else {
            await studentRef.update({
              'currentScore': score,
              'lastAttempt': DateTime.now(),
            });
          }
        } else {
          await studentRef.set({
            'currentScore': score,
            'maxScore': score,
            'lastAttempt': DateTime.now(),
          });
        }
      }

      void _calculateScore() async {
        if (selectedAnswers.length != await _firestore
            .collection('quizzes')
            .doc(widget.quizzId)
            .collection('questions')
            .get()
            .then((value) => value.docs.length)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please answer all questions before submitting'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        double score = 0.0;
        var questionsSnapshot = await _firestore
            .collection('quizzes')
            .doc(widget.quizzId)
            .collection('questions')
            .get();

        for (var doc in questionsSnapshot.docs) {
          var questionData = doc.data();
          var questionId = questionData['questionId'];
          var correctAnswer = questionData['correctAnswer'];
          double marks = questionData['marksOfQn'] ?? 0;

          if (selectedAnswers[questionId] == correctAnswer) {
            score += marks;
          }
        }
        await _saveScore(score);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text('Quiz Results',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 50,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Score: $score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); 
                  },
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
            title: const Text('Quiz Questions'),
            centerTitle: true,
          ),
          body: FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('quizzes')
                .doc(widget.quizzId)
                .collection('questions')
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var questionData = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        var questionId = questionData['questionId'] ?? '';
                        var mcqOptions =
                            List<String>.from(questionData['mcqOptions'] ?? []);
                        var marks = questionData['marksOfQn'] ?? 0;

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Question ${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Marks: $marks',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  questionData['questionText'] ?? 'No question',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...mcqOptions.map((option) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: selectedAnswers[questionId] == option
                                              ? Colors.blue
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: RadioListTile<String>(
                                        title: Text(option),
                                        value: option,
                                        groupValue: selectedAnswers[questionId],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedAnswers[questionId] = value!;
                                          });
                                        },
                                        activeColor: Colors.blue,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _calculateScore,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle),
                          SizedBox(width: 8),
                          Text(
                            'Submit Quiz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }
