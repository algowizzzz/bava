import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../gemini/gemini_screen.dart';

class HandoutAssignmentPage extends StatefulWidget {
  @override
  _HandoutAssignmentPageState createState() => _HandoutAssignmentPageState();
}

class _HandoutAssignmentPageState extends State<HandoutAssignmentPage> {
  String? selectedClassSubject;
  String selectedQuestionType = 'MCQ';

  final TextEditingController handoutController = TextEditingController();
  final TextEditingController assignmentTopicController = TextEditingController();
  final TextEditingController numberOfQuestionsController = TextEditingController();
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  final List<String> questionTypeOptions = ['MCQ', 'Descriptive', 'True/False', 'Fill in the Blanks'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handout & Assignment'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.purple, Colors.black87],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              shadowColor: Colors.black54,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('history')
                          .where('userUid', isEqualTo: currentUserUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();

                        // Extract unique class-subject combinations
                        List<String> classSubjectList = snapshot.data!.docs
                            .map((doc) => '${doc['className']} - ${doc['subject']}')
                            .toSet() // Remove duplicates
                            .toList();

                        return buildDropdown(
                          'Class and Subject',
                          selectedClassSubject ?? '',
                          classSubjectList,
                              (value) {
                            setState(() {
                              selectedClassSubject = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    buildTextField('Enter Handout Content', handoutController, 'Enter the handout content here', maxLines: 5),
                    const SizedBox(height: 20),
                    buildTextField('Enter Assignment Topic', assignmentTopicController, 'Enter the assignment topic here'),
                    const SizedBox(height: 20),
                    buildTextField('Enter Number of Questions', numberOfQuestionsController, 'Enter the number of questions here', keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    buildDropdown('Select Type of Questions', selectedQuestionType, questionTypeOptions, (newValue) {
                      setState(() {
                        selectedQuestionType = newValue!;
                      });
                    }),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.purpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          String handout = handoutController.text.trim();
                          String assignmentTopic = assignmentTopicController.text.trim();
                          String numberOfQuestions = numberOfQuestionsController.text.trim();
                          String typeOfQuestions = selectedQuestionType;

                          String validationPrompt = 'Is the handout content "$handout" and the assignment topic "$assignmentTopic" relevant to the subject "$selectedClassSubject"? Please answer with yes or no.';

                          validateHandoutAssignment(handout, assignmentTopic, numberOfQuestions, typeOfQuestions, validationPrompt);
                        },
                        child: const Text(
                          'Generate Handout & Assignment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value!.isEmpty ? null : value,  // Ensure non-empty value is passed
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          dropdownColor: Colors.deepPurpleAccent,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildTextField(String label, TextEditingController controller, String hintText, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: hintText,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  void validateHandoutAssignment(String handout, String assignmentTopic, String numberOfQuestions, String typeOfQuestions, String validationPrompt) async {
    if (handout.isEmpty || assignmentTopic.isEmpty || numberOfQuestions.isEmpty || typeOfQuestions.isEmpty) {
      showErrorDialog('Please fill in all fields.');
      return;
    }

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      // Assuming the `GenerativeModel` is defined elsewhere
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      final content = [Content.text(validationPrompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        if (response.text!.toLowerCase().startsWith('yes')) {
          String prompt = "Act as qualified CBSE school teacher from India of class $selectedClassSubject Generate a handout for on $selectedClassSubject more than 200 words. "
              "Handout Content: $handout. \nAssignment Topic: $assignmentTopic. "
              "Number of Questions: $numberOfQuestions. Type of Questions: $typeOfQuestions.";

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => geminiScreen(
                prompt: prompt,
                contentType: 'Handout',
              ),
            ),
          );
        } else {
          showErrorDialog('The handout content or assignment topic is not valid for the $selectedClassSubject.');
        }
      } else {
        showErrorDialog('No response from the model.');
      }
    } catch (e) {
      showErrorDialog('Error validating handout content: $e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(
            message,
            style: const TextStyle(color: Colors.red),
          ),
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
}
