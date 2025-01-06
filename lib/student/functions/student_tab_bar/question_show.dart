import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionShow extends StatefulWidget {
  @override
  _QuestionShowState createState() => _QuestionShowState();
}

class _QuestionShowState extends State<QuestionShow> {
  List _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    String jsonString = await rootBundle.loadString('assets/question.json');
    setState(() {
      final Map<String, dynamic> data = json.decode(jsonString);
      _questions = data['questions'];
    });
  }

  void _checkAnswer(bool isCorrect) {
    if (!_isAnswered) {
      setState(() {
        _isAnswered = true;
        if (isCorrect) {
          _score++;
        }
      });

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          if (_currentQuestionIndex < _questions.length - 1) {
            _currentQuestionIndex++;
            _isAnswered = false;
          } else {
            // Quiz completed
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Quiz Completed!'),
                  content: Text('Your score: $_score/${_questions.length}'),
                  actions: [
                    TextButton(
                      child: Text('Restart'),
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex = 0;
                          _score = 0;
                          _isAnswered = false;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: _questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              _questions[_currentQuestionIndex]['questionText'],
              style: TextStyle(fontSize: 18, color: Colors.black),  // Set color to black
            ),
            SizedBox(height: 20),
            ...(_questions[_currentQuestionIndex]['answers'] as List)
                .map<Widget>((answer) {
              bool isSelected = _isAnswered && answer['score'] == true;
              bool isWrong = _isAnswered && answer['score'] == false;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Colors.green
                        : isWrong
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () => _checkAnswer(answer['score']),
                  child: Text(answer['text']),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
