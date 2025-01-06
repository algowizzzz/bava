import 'package:chatbot/screens/gemini/gemini_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class PPTGeneratorPage extends StatefulWidget {
  @override
  _PPTGeneratorPageState createState() => _PPTGeneratorPageState();
}

class _PPTGeneratorPageState extends State<PPTGeneratorPage> {
  final TextEditingController topicController = TextEditingController();
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  String? selectedClassSubject;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPT Generator', style: TextStyle(fontFamily: 'Montserrat')),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Container(
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: buildCard(),
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildCard() {
    return Card(
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
                  selectedClassSubject ?? '',
                  classSubjectList,
                      (value) => setState(() => selectedClassSubject = value),
                );
              },
            ),
            const SizedBox(height: 20),
            buildTextField(
              'Enter Topic',
              topicController,
              'Enter your PPT topic here',
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
                  elevation: 5,
                ),
                onPressed: () {
                  String topic = topicController.text.trim();
                  String? className = selectedClassSubject?.split(' - ').first;
                  String? subject = selectedClassSubject?.split(' - ').last;

                  validateLessonTopicAndNavigate(className, subject, topic);
                },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                  'Generate PPT',
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
    );
  }

  Widget buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16, fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isNotEmpty ? value : null,
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
              child: Text(
                option,
                style: const TextStyle(color: Colors.black87),
              ),
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
      isLoading = true;
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

      String validationPrompt = 'Is the topic "$topic" suitable for the subject $selectedClassSubject? Please answer with yes or no.';
      final content = [Content.text(validationPrompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        if (response.text!.toLowerCase().startsWith('yes')) {
          // Validate for duplicates
          bool isDuplicate = await isDuplicateEntry(topic, className, subject, model);
          if (isDuplicate) {
            showErrorDialog('Error: This topic has already been generated for the $selectedClassSubject".');
            return; // Stop execution here to not navigate
          }

          String prompt = "Act as a qualified CBSE school Teacher from India of  $selectedClassSubject specializes in teaching and generate a slide by slide presentation for teaching the topic: $topic";

          // Navigate only if no errors occurred
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => geminiScreen(
                prompt: prompt,
                contentType: 'ppt',
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
        isLoading = false;
      });
    }
  }

  Future<bool> isDuplicateEntry(String topic, String className, String subject, GenerativeModel model) async {
    // Normalize the topic by removing spaces and converting to lowercase
    String normalizedTopic = topic.replaceAll(' ', '').toLowerCase();

    // Perform a query in the database to check for an existing entry
    var querySnapshot = await FirebaseFirestore.instance
        .collection('history') // Update this to your actual collection name
        .where('className', isEqualTo: className)
        .where('subject', isEqualTo: subject)
        .get();

    for (var doc in querySnapshot.docs) {
      String existingTopic = doc['topic'];

      // Ask Gemini if the topics are considered equivalent
      final prompt = 'Are "${topic}," and "$existingTopic" referring to the same topic?';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.toLowerCase().contains('yes')) {
        return true; // Duplicate found
      }
    }

    return false; // No duplicates found
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
