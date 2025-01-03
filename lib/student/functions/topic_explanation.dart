import 'package:chatbot/student/gemini_student.dart';
import 'package:flutter/material.dart';

class TopicExplanationPage extends StatefulWidget {
  final String className ;
  const TopicExplanationPage({super.key, required this.className});

  @override
  _TopicExplanationPageState createState() => _TopicExplanationPageState();
}

class _TopicExplanationPageState extends State<TopicExplanationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _submit() {
    String prompt= 'Act as an Experienced Teacher who is teaching in a CBSE School in India of ${widget.className}, Explain me, a student of${widget.className}, the topic of ${_controller.text} in detail using definitions, real life examples, and questions with answers to explain the topic better.';
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  geminiStudent(
            prompt:prompt,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Topic Explanation"),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Form to enter topic explanation
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter Topic Explanation',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a topic explanation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
