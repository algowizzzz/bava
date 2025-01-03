import 'package:chatbot/screens/gemini/gemini_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApplicationRealLife extends StatefulWidget {
  @override
  _ApplicationRealLifeState createState() => _ApplicationRealLifeState();
}

class _ApplicationRealLifeState extends State<ApplicationRealLife> {
  final TextEditingController topicController = TextEditingController();
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  String? selectedClassSubject;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Context Builder', style: TextStyle(fontFamily: 'Montserrat')),
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
                  Color(0xFF6A1B9A), // Deep purple shade
                  Color(0xFF8E24AA), // Lighter purple shade
                  Color(0xFFBA68C8), // Lavender shade
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
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('history')
                  .where('userUid', isEqualTo: currentUserUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                List<String> classSubjectList = snapshot.data!.docs
                    .map((doc) => '${doc['className']} - ${doc['subject']}')
                    .map((item) => item.toLowerCase().replaceAll(' ', '')) // Normalize the case and spaces
                    .toSet() // Removes duplicates
                    .toList();

                // Ensure selectedClassSubject is in the list of items
                if (selectedClassSubject != null && !classSubjectList.contains(selectedClassSubject!.toLowerCase().replaceAll(' ', ''))) {
                  selectedClassSubject = null;  // Reset to null if it's no longer a valid item
                }

                return buildDropdown(
                  'Class and Subject',
                  selectedClassSubject ?? '',  // Ensure value is not null
                  classSubjectList,
                      (value) => setState(() => selectedClassSubject = value),
                );
              },
            ),
            const SizedBox(height: 20),
            buildTextField(
              'Enter Topic',
              topicController,
              'Enter your Application in real life topic here',
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
                  if (selectedClassSubject == null || selectedClassSubject!.isEmpty) {
                    showErrorDialog('Please select a class and subject.');
                    return;
                  }
                  if (topic.isEmpty) {
                    showErrorDialog('Please enter a topic.');
                    return;
                  }
                  String validationPrompt = 'Is the topic "$topic" relevant to the subject "$selectedClassSubject"? Please answer with yes or no.';
                  validateTopic(topic, validationPrompt);
                },
                child: const Text(
                  'Generate Applications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat'),
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
          value: value.isEmpty ? null : value,  // Ensure it is null if the value is empty
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

  void validateTopic(String topic, String validationPrompt) async {
    setState(() => isLoading = true);

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      final content = [Content.text(validationPrompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        if (response.text!.toLowerCase().startsWith('yes')) {
          String prompt = "Act as a qualified CBSE school Teacher from India of $selectedClassSubject who specializes in teaching. Generate a list of real-life applications for the topic: $topic";

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => geminiScreen(
                prompt: prompt, contentType: 'Real Life Applications',
              ),
            ),
          );
        } else {
          showErrorDialog('The topic is not valid for the selected subject.');
        }
      } else {
        showErrorDialog('No response from the model.');
      }
    } catch (e) {
      showErrorDialog('Error validating topic: $e');
    } finally {
      setState(() => isLoading = false);
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
