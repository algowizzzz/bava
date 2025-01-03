import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../gemini_student.dart';

class ReviewQuestionPage extends StatefulWidget {
  final String studentId;
  final String classNAme;
  const ReviewQuestionPage({super.key, required this.studentId, required this.classNAme});

  @override
  _ReviewQuestionPageState createState() => _ReviewQuestionPageState();
}

class _ReviewQuestionPageState extends State<ReviewQuestionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numberOfQuestionsController = TextEditingController();
  final TextEditingController _questionTypeController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  String? _selectedSubject;

  @override
  void dispose() {
    _numberOfQuestionsController.dispose();
    _questionTypeController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String prompt = '''
      Act as an Experienced Teacher in a CBSE School of ${widget.classNAme}. 
      Evaluate the following questions created for the topic '${_topicController.text}' under the subject '$_selectedSubject'. 
      The question type is '${_questionTypeController.text}' and the total number of questions is ${_numberOfQuestionsController.text}. 
      Provide feedback on how to improve the questions, their structure, and suggest any points to enhance them further.
      ''';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => geminiStudent(prompt: prompt),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Questions"),
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Review Questions",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigoAccent,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Provide details to review and improve your questions.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                // StreamBuilder for subjects
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .where('id', isEqualTo: widget.studentId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("Error fetching data"));
                    }

                    Set<String> subjectsSet = {};
                    for (var student in snapshot.data!.docs) {
                      var studentData = student.data() as Map<String, dynamic>;
                      List<dynamic> subjects = studentData['subjects'] ?? [];
                      for (var subject in subjects) {
                        subjectsSet.add(subject.toString());
                      }
                    }

                    List<String> subjectsList = subjectsSet.toList();
                    return DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: Icon(Icons.subject, color: Colors.indigoAccent),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSubject = newValue;
                        });
                      },
                      items: subjectsList
                          .map((subjectItem) => DropdownMenuItem<String>(
                        value: subjectItem,
                        child: Text(subjectItem),
                      ))
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a subject';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Topic Input
                _buildTextInput(
                  controller: _topicController,
                  label: "Topic",
                  icon: Icons.topic,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a topic';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Question Type Input
                _buildTextInput(
                  controller: _questionTypeController,
                  label: "Question Type",
                  icon: Icons.question_answer,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the question type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Number of Questions Input
                _buildTextInput(
                  controller: _numberOfQuestionsController,
                  label: "Number of Questions",
                  icon: Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of questions';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: Colors.indigoAccent),
      ),
      validator: validator,
    );
  }
}
