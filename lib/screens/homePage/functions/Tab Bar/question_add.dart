import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionAdd extends StatefulWidget {
  const QuestionAdd({Key? key}) : super(key: key);

  @override
  State<QuestionAdd> createState() => _QuestionAddState();
}

class _QuestionAddState extends State<QuestionAdd> {
  final _formKey = GlobalKey<FormState>();
  final _quizNameController = TextEditingController();
  final _questionCountController = TextEditingController();

  @override
  void dispose() {
    _quizNameController.dispose();
    _questionCountController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionDetails(
            quizName: _quizNameController.text,
            questionCount: int.parse(_questionCountController.text),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Quiz Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _quizNameController,
                decoration: const InputDecoration(labelText: 'Quiz Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionCountController,
                decoration: const InputDecoration(labelText: 'Number of Questions'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number of questions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _nextPage,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionDetails extends StatefulWidget {
  final String quizName;
  final int questionCount;

  const QuestionDetails({
    Key? key,
    required this.quizName,
    required this.questionCount,
  }) : super(key: key);

  @override
  State<QuestionDetails> createState() => _QuestionDetailsState();
}

class _QuestionDetailsState extends State<QuestionDetails> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _questionControllers = [];
  final List<List<TextEditingController>> _optionControllers = [];
  final List<String> _questionTypes = [];
  final List<TextEditingController> _marksControllers = [];
  final List<TextEditingController> _correctAnswerControllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.questionCount; i++) {
      _questionControllers.add(TextEditingController());
      _optionControllers.add(List.generate(4, (index) => TextEditingController()));
      _questionTypes.add('MCQ'); // Default type
      _marksControllers.add(TextEditingController());
      _correctAnswerControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    for (var list in _optionControllers) {
      for (var controller in list) {
        controller.dispose();
      }
    }
    for (var controller in _marksControllers) {
      controller.dispose();
    }
    for (var controller in _correctAnswerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuizToFirebase() async {
    if (_formKey.currentState?.validate() ?? false) {
      final quizDoc = FirebaseFirestore.instance.collection('quizzes').doc();

      // Quiz Metadata
      final quizData = {
        'quizId': quizDoc.id,
        'quizName': widget.quizName,
        'noOfQns': widget.questionCount,
        'totalMarksQuiz': _marksControllers.fold<int>(
          0,
              (sum, controller) {
            final value = int.tryParse(controller.text);
            return sum + (value ?? 0);
          },
        ),
      };

      // Questions Data
      final questionsData = [];
      for (int i = 0; i < widget.questionCount; i++) {
        questionsData.add({
          'quizId': quizDoc.id,
          'questionId': '$i',
          'questionType': _questionTypes[i],
          'questionText': _questionControllers[i].text,
          'mcqOptions': _questionTypes[i] == 'MCQ'
              ? _optionControllers[i].map((c) => c.text).toList()
              : [],
          'correctAnswer': _correctAnswerControllers[i].text,
          'marksOfQn': int.tryParse(_marksControllers[i].text) ?? 0,
        });
      }

      await quizDoc.set(quizData);
      for (var question in questionsData) {
        await quizDoc.collection('questions').add(question);
      }

      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Questions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Quiz: ${widget.quizName}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < widget.questionCount; i++) ...[
                  TextFormField(
                    controller: _questionControllers[i],
                    decoration: InputDecoration(labelText: 'Question ${i + 1}'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter question ${i + 1}';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _questionTypes[i],
                    decoration: const InputDecoration(labelText: 'Question Type'),
                    items: const [
                      DropdownMenuItem(child: Text('MCQ'), value: 'MCQ'),
                      DropdownMenuItem(child: Text('Single Word'), value: 'Single Word'),
                      DropdownMenuItem(child: Text('Single Answer'), value: 'Single Answer'),
                      DropdownMenuItem(child: Text('Long Text'), value: 'Long Text'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _questionTypes[i] = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a question type';
                      }
                      return null;
                    },
                  ),
                  if (_questionTypes[i] == 'MCQ')
                    for (int j = 0; j < 4; j++)
                      TextFormField(
                        controller: _optionControllers[i][j],
                        decoration: InputDecoration(labelText: 'Option ${j + 1}'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter option ${j + 1}';
                          }
                          return null;
                        },
                      ),
                  TextFormField(
                    controller: _correctAnswerControllers[i],
                    decoration: const InputDecoration(labelText: 'Correct Answer'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the correct answer';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _marksControllers[i],
                    decoration: const InputDecoration(labelText: 'Marks for Question'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null) {
                        return 'Please enter valid marks';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: _saveQuizToFirebase,
                  child: const Text('Save Quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
