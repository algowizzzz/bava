import 'dart:convert';

import 'package:chatbot/screens/ppt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';

class geminiStudent extends ConsumerStatefulWidget {
  final String prompt;


  const geminiStudent({
    required this.prompt,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<geminiStudent> createState() => _geminiScreenState();
}

class _geminiScreenState extends ConsumerState<geminiStudent> {
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
    super.initState();
    generateContent(widget.prompt);
  }

  Future<void> generatePowerPoint(String title, List<String> slideContents) async {
    const apiKey = '22604833-8125-492e-8c39-ba5563738f22'; // Replace with your actual API key
    const apiUrl = 'https://auth.powerpointgeneratorapi.com/v1.0/token/create';

    // Prepare the JSON body with the required title and content for each slide
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
      // Handle success, e.g., get the download URL or binary data
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

        // Initialize Gemini Model
        final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

        // Generate content based on user input
        final content = [Content.text('Generate content based on this ${widget.prompt}: $userMessage')];
        final response = await model.generateContent(content);

        // Display the response in the chat box
        setState(() {
          _chatResponse = formatText(response.text ?? 'No response from the model');
          _isLoading = false; // Stop loading after the response is generated
        });

      } catch (e) {
        // Error handling
        setState(() {
          _chatResponse = 'Error generating response: $e';
          _isLoading = false; // Stop loading on error
        });
      }

      // Clear the input field after submission
      _chatController.clear();
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
          'Student Assistant',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
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
                            color: Colors.grey[200],
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
                  //     onPressed:(){
                  //       generatePowerPoint(
                  //         "My Presentation",
                  //         ["Introduction to the Topic", "Details and Key Points", "Conclusion"],
                  //       );
                  //       // Navigator.push(context, MaterialPageRoute(builder: (context) => PPTGenerator(Text: _response.toString(),),));
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
