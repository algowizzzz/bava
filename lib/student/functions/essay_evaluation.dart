import 'package:flutter/material.dart';

import '../gemini_student.dart';

class EssayEvaluationPage extends StatefulWidget {
  final String className;
  const EssayEvaluationPage({super.key, required this.className});

  @override
  _EssayEvaluationPageState createState() => _EssayEvaluationPageState();
}

class _EssayEvaluationPageState extends State<EssayEvaluationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _essayController = TextEditingController();
  String _evaluationResult = '';

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  void _evaluateEssay() {
    String essay = _essayController.text;
    if (essay.length < 100) {
      _evaluationResult = 'Essay is too short. Please write more details.';
    } else if (essay.length < 300) {
      _evaluationResult = 'Essay is average. Consider adding more depth.';
    } else {
      _evaluationResult = 'Great job! Your essay is well-written and comprehensive.';

    }
    String prompt= 'Act as an Experienced English Teacher who is teaching in a CBSE School in India of ${widget.className}. Evaluate the below Essay written by a student of class ${widget.className}give Points on how to improve the essay, better the structure, and anymore points to add on the topic of ${_essayController.text}';
    Navigator.push(context, MaterialPageRoute(builder: (context) => geminiStudent(prompt: prompt,),));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Essay Evaluation"),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter your Essay below for Evaluation:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
            ),
            const SizedBox(height: 20),
            // Form to enter essay
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _essayController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Write your essay here...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your essay';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _evaluateEssay,
                    child: const Text('Submit for Evaluation',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Display evaluation result
            if (_evaluationResult.isNotEmpty)
              Text(
                'Evaluation Result: $_evaluationResult',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}
