import 'dart:convert';

import 'package:chatbot/screens/ppt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';

class geminiScreen extends ConsumerStatefulWidget {
  final String prompt;
  final String? documentId;
  final String contentType;
  final String? topicId;

  const geminiScreen({
    required this.prompt,
    this.documentId,
    this.topicId,
    required this.contentType,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<geminiScreen> createState() => _geminiScreenState();
}

class _geminiScreenState extends ConsumerState<geminiScreen> {
  final TextEditingController _chatController = TextEditingController();
  String? _response;
  String? _chatResponse;
  bool _isLoading = false;
  bool _isLoadingg = false;

  String formatText(String text) {
    return text
        .replaceAll('*', ' ')
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => '${match[1]}'.toUpperCase());
  }

  @override
  void initState() {
    print(widget.topicId);
    print("prompt:${widget.prompt}");
    print(widget.contentType);
    super.initState();
    generateContent(widget.prompt);
  }

  Future<void> generatePowerPoint(String title, List<String> slideContents) async {
    const apiKey = '22604833-8125-492e-8c39-ba5563738f22';
    const apiUrl = 'https://auth.powerpointgeneratorapi.com/v1.0/token/create';
    final body = {
      "title": title,
      "slides": slideContents.map((content) => {"text": content}).toList(),
    };

    // Send the POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final downloadUrl = jsonResponse['download_url'];
      print("Download your PPT from: $downloadUrl");
    } else {
      print("Failed to generate PPT: ${response.body}");
    }
  }

  Future<void> generateContent(String userMessage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Please define it in the .env file.');
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final content = [Content.text('Generate content based on this ${widget.prompt}: $userMessage')];
      final response = await model.generateContent(content);

      if (response.text != null) {
        setState(() {
          _response = formatText(response.text!);
        });

        if (widget.documentId != null) {
          final fieldToUpdate = _getFieldBasedOnContentType(widget.contentType);
          await FirebaseFirestore.instance.collection('history').doc(widget.documentId).collection('topics').doc(widget.topicId).update({
            fieldToUpdate: _response,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        throw Exception('No valid response from the model.');
      }
    } catch (e) {
      showErrorDialog('Error generating content: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> handleChatSubmit() async {
    String userMessage = _chatController.text.trim();

    if (userMessage.isNotEmpty) {
      setState(() {
        _isLoading = true; // Start loading
        _chatResponse = "Generating response..."; // Optional loading message
      });

      try {
        // Ensure the API key is available
        String? apiKey = dotenv.env['GOOGLE_API_KEY'];
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('API Key is missing. Make sure it is defined in the .env file.');
        }
        final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
        final content = [Content.text('Generate content based on this ${widget.prompt}: $userMessage')];
        final response = await model.generateContent(content);
        setState(() {
          _chatResponse = formatText(response.text ?? 'No response from the model');
          _isLoading = false; // Stop loading after the response is generated
        });
        if (widget.documentId != null) {
          final fieldToUpdate = _getFieldBasedOnContentType(widget.contentType);
          await FirebaseFirestore.instance.collection('history').doc(widget.documentId).collection('topics').doc('specificTopicId').update({
            fieldToUpdate: _chatResponse,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        setState(() {
          _chatResponse = 'Error generating response: $e';
          _isLoading = false; // Stop loading on error
        });
      }
      _chatController.clear();
    }
  }

  String _getFieldBasedOnContentType(String contentType) {
    switch (contentType) {
      case 'lesson plan':
        return 'lessonPlan';
      case 'ppt':
        return 'ppt';
      case 'handout':
        return 'handout';
      case 'contextBuilder':
        return 'contextBuilder';
      case 'applicationsInRealLife':
        return 'applicationsInRealLife';
      default:
        return 'generatedContent';
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message, style: const TextStyle(color: Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Assistant',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade700, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Display the response or loading indicator
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            _response ?? 'No response generated yet.',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                      // Display the chat response or loading indicator
                      if (_isLoadingg && _chatResponse == null)
                        const CircularProgressIndicator()
                      else
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            _chatResponse.toString(),
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        labelText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      handleChatSubmit();
                    },
                  ),
                  // Button to generate and open PPT
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       generatePowerPoint("Sample PPT", ['Slide 1 Content', 'Slide 2 Content']);
                  //     },
                  //     child: const Text('Generate PPT'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
