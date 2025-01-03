import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../gemini/gemini_lessonplan.dart';

class LessonPlannerPage extends StatefulWidget {
  @override
  _LessonPlannerPageState createState() => _LessonPlannerPageState();
}

class _LessonPlannerPageState extends State<LessonPlannerPage> {
  final TextEditingController lessonController = TextEditingController();
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  String? selectedClassSubject;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Planner', style: TextStyle(fontFamily: 'Montserrat')),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF8E24AA),
              Color(0xFFBA68C8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
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

                        List<String> classSubjectList = snapshot.data!.docs
                            .map((doc) => '${doc['className']} - ${doc['subject']}')
                            .toSet()
                            .toList();

                        return buildDropdown(
                          'Class and Subject',
                          selectedClassSubject,
                          classSubjectList,
                              (value) => setState(() => selectedClassSubject = value!),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      'Enter Topic',
                      lessonController,
                      'Enter your lesson topic here',
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.purpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                        ),
                        onPressed: () {
                          String topic = lessonController.text.trim();
                          String? className = selectedClassSubject?.split(' - ').first;
                          String? subject = selectedClassSubject?.split(' - ').last;

                          validateLessonTopicAndNavigate(className, subject, topic);
                        },
                        child:  _isLoading ? CircularProgressIndicator() : Text(
                          'Generate Lesson Plan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16, fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
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

  Widget buildTextField(String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16, fontFamily: 'Montserrat'),
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
          maxLines: 5,
          maxLength: 100,
        ),
      ],
    );
  }

  Future<void> validateLessonTopicAndNavigate(String? className, String? subject, String topic) async {
    if (className == null || subject == null || topic.isEmpty) {
      showErrorDialog('Please fill in all fields (class name, subject, and lesson topic).');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      String validationPrompt = 'Is the topic "$topic" suitable for the $selectedClassSubject"? Please answer with yes or no.';
      final content = [Content.text(validationPrompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        if (response.text!.toLowerCase().startsWith('yes')) {
          bool isDuplicate = await isDuplicateEntry(topic, className, subject, model);
          if (isDuplicate) {
            showErrorDialog('Error: This topic has already been generated for the  $selectedClassSubject".');
            return;
          }

          String prompt = "Act as a qualified CBSE school Teacher from India of $selectedClassSubject who specializes in teaching  and generate a lesson planner for teaching the topic: $topic";

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => geminiLessonPlan(
                prompt: prompt,
                className: className,
                subject: subject,
                validationPrompt: validationPrompt,
                topic: topic,
                onValidationError: (String error) {
                  showErrorDialog(error);
                },
              ),
            ),
          );
        } else {
          showErrorDialog('The lesson topic is not suitable for the selected subject and class.');
        }
      } else {
        showErrorDialog('No response from the model.');
      }
    } catch (e) {
      showErrorDialog('Error validating lesson topic: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> isDuplicateEntry(String topic, String className, String subject, GenerativeModel model) async {
    // Normalize the topic by removing spaces and converting to lowercase for comparison
    String normalizedTopic = topic.replaceAll(' ', '').toLowerCase();

    // Query Firestore for any document that matches the provided className and subject
    var querySnapshot = await FirebaseFirestore.instance
        .collection('history')
        .where('className', isEqualTo: className)
        .where('userUid', isEqualTo: currentUserUid)
        .where('subject', isEqualTo: subject)
        .get();

    for (var doc in querySnapshot.docs) {
      String existingTopic = doc['topic'];
      String documentId = doc.id;  // Get the document ID for reference

      // If there is no topic in the document, continue to the next one
      if (existingTopic.isEmpty) {
        continue;
      }

      // Normalize the existing topic for comparison
      String normalizedExistingTopic = existingTopic.replaceAll(' ', '').toLowerCase();

      // Directly compare normalized topics to see if they are identical
      if (normalizedTopic == normalizedExistingTopic) {
        // showErrorDialog('Error: The topic "$topic" has already been generated for class "$className" and subject "$subject" (Document ID: $documentId).');
        return true;
      }

      // Use AI model to further check if the topics are deemed similar
      final prompt = 'Are "$topic" and "$existingTopic" referring to the same topic?';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      // If the model indicates a match, display an error message and return true
      if (response.text != null && response.text!.toLowerCase().contains('yes')) {
        showErrorDialog('Error: The topic "$topic" is similar to an existing topic "$existingTopic" for class "$className" and subject "$subject" (Document ID: $documentId).');
        return true;
      }
    }

    // No duplicates found, return false
    return false;
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
