import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionAdd extends StatefulWidget {
  String classname;
  String subject;
  QuestionAdd({Key? key, required this.classname, required this.subject}) : super(key: key);

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
            classname: widget.classname,
            subject: widget.subject,
            quizName: _quizNameController.text,
            questionCount: int.parse(_questionCountController.text),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _quizNameController,
                      decoration: InputDecoration(
                        labelText: 'Quiz Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quiz name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _questionCountController,
                      decoration: InputDecoration(
                        labelText: 'Number of Questions',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Please enter a valid number of questions';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionDetails extends StatefulWidget {
  final String quizName;
  final int questionCount;
 final String classname;
 final String subject;

  const QuestionDetails({
    Key? key,
    required this.quizName,
    required this.classname,  
    required this.subject,  
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
  final List<List<String>> _mcqOptions = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.questionCount; i++) {
      _questionControllers.add(TextEditingController());
      _optionControllers
          .add(List.generate(4, (index) => TextEditingController()));
      _questionTypes.add('MCQ');
      _marksControllers.add(TextEditingController());
      _correctAnswerControllers.add(TextEditingController());
      _mcqOptions.add([]);
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

      final quizData = {
        'quizId': quizDoc.id,
        'quizName': widget.quizName,
        'noOfQns': widget.questionCount,
           'class': widget.classname,
          'subjects':  widget.subject,

        'totalMarksQuiz': _marksControllers.fold<int>(
          0,
          (sum, controller) {
            final value = int.tryParse(controller.text);
            return sum + (value ?? 0);
          },
        ),
      };

      final questionsData = [];
      for (int i = 0; i < widget.questionCount; i++) {
        questionsData.add({
          'quizId': quizDoc.id,
          'questionId': '$i',
          'questionType': _questionTypes[i],
          'questionText': _questionControllers[i].text,
          'mcqOptions': _questionTypes[i] == 'MCQ' ? _mcqOptions[i] : [],
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
      appBar: AppBar(
        title: const Text('Add Questions'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Quiz: ${widget.quizName}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 24),
                          for (int i = 0; i < widget.questionCount; i++) ...[
                            Card(
                              margin: const EdgeInsets.only(bottom: 24),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Question ${i + 1}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _questionControllers[i],
                                      decoration: InputDecoration(
                                        labelText: 'Question Text',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                      ),
                                      maxLines: 2,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter question ${i + 1}';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: _questionTypes[i],
                                      decoration: InputDecoration(
                                        labelText: 'Question Type',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            child: Text('MCQ'), value: 'MCQ'),
                                        DropdownMenuItem(
                                            child: Text('Single Word'),
                                            value: 'Single Word'),
                                        DropdownMenuItem(
                                            child: Text('Single Answer'),
                                            value: 'Single Answer'),
                                        DropdownMenuItem(
                                            child: Text('Long Text'),
                                            value: 'Long Text'),
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
                                    if (_questionTypes[i] == 'MCQ') ...[
                                      const SizedBox(height: 16),
                                      for (int j = 0; j < 4; j++) ...[
                                        TextFormField(
                                          controller: _optionControllers[i][j],
                                          decoration: InputDecoration(
                                            labelText: 'Option ${j + 1}',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _mcqOptions[i] =
                                                  _optionControllers[i]
                                                      .map((controller) =>
                                                          controller.text)
                                                      .toList();
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter option ${j + 1}';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      DropdownButtonFormField<String>(
                                        value: _correctAnswerControllers[i]
                                                .text
                                                .isEmpty
                                            ? null
                                            : _correctAnswerControllers[i].text,
                                        decoration: InputDecoration(
                                          labelText: 'Correct Answer',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                        ),
                                        items: _mcqOptions[i].map((option) {
                                          return DropdownMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _correctAnswerControllers[i].text =
                                                value ?? '';
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select the correct answer';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _marksControllers[i],
                                      decoration: InputDecoration(
                                        labelText: 'Marks for Question',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            int.tryParse(value) == null) {
                                          return 'Please enter valid marks';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveQuizToFirebase,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Quiz',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
