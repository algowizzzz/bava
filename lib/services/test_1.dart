import 'package:chatbot/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPdfMessagePage extends StatefulWidget {
  final String sourceId;

  ChatPdfMessagePage({required this.sourceId});

  @override
  _ChatPdfMessagePageState createState() => _ChatPdfMessagePageState();
}

class _ChatPdfMessagePageState extends State<ChatPdfMessagePage> {
  TextEditingController _messageController = TextEditingController();
  String _responseMessage = '';
  String _introductoryMessage = '';
  List<String> _questions = []; // Store the generated questions
  bool _isLoading = false;
  bool _isFetchingIntro = true;

  String apiKey = 'sec_fE4xOxJMfiXT5OiTtVPOIFH0dzHbvjaa'; // Replace with your actual API key

  // Fetch introductory message from the ChatPDF API
  Future<void> fetchIntroductoryMessage() async {
    setState(() {
      _isFetchingIntro = true;
    });

    final url = Uri.parse('https://api.chatpdf.com/v1/chats/message');
    final headers = {
      'x-api-key': apiKey,
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'sourceId': widget.sourceId,
      'messages': [
        {
          'role': 'user',
          'content': 'Provide a summary of the document and suggest three example questions a user can ask about the file.',
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'] ?? '';
        // Extract questions if present
        final questionPattern = RegExp(r'\d\.\s+(.*?)(?=\n|$)');
        final matches = questionPattern.allMatches(content).map((e) => e.group(1) ?? '').toList();

        setState(() {
          _introductoryMessage = content;
          _questions = matches; // Save the questions
        });
      } else {
        setState(() {
          _introductoryMessage = 'Error fetching introductory message: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _introductoryMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isFetchingIntro = false;
      });
    }
  }

  // Fetch the answer for the clicked question number
  void fetchAnswerForQuestionNumber(int questionNumber) {
    if (questionNumber > 0 && questionNumber <= _questions.length) {
      String selectedQuestion = _questions[questionNumber - 1];
      sendMessageToChatPdf(selectedQuestion);
    } else {
      setState(() {
        _responseMessage = 'Invalid question number.';
      });
    }
  }

  // Function to send a message to the ChatPDF API
  Future<void> sendMessageToChatPdf(String message) async {
    setState(() {
      _isLoading = true;
      _responseMessage = ''; // Clear previous response
    });

    final url = Uri.parse('https://api.chatpdf.com/v1/chats/message');
    final headers = {
      'x-api-key': apiKey,
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'sourceId': widget.sourceId,
      'messages': [
        {
          'role': 'user',
          'content': message,
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _responseMessage = formatText(data['content'] ?? 'No content in response');
        });
      } else {
        setState(() {
          _responseMessage = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to format text
  String formatText(String text) {
    // Replace **bold** with uppercase
    String formattedText = text.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) {
      return '${match[1]}'.toUpperCase(); // Convert to uppercase
    });

    // Replace *text* with bullet points
    formattedText = formattedText.replaceAll('*', '\n• ');

    // Remove the four hash symbols (####) and keep the text
    formattedText = formattedText.replaceAllMapped(RegExp(r'####(.*?)'), (match) {
      return match[1]!; // Return the text inside without the four hash symbols
    });

    // Remove the triple hash symbols (###) and keep the text
    formattedText = formattedText.replaceAllMapped(RegExp(r'###(.*?)'), (match) {
      return match[1]!; // Keep the text and remove the hash symbols
    });

    return formattedText;
  }

  @override
  void initState() {
    super.initState();
    fetchIntroductoryMessage(); // Fetch the introductory message when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatPDF'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Introductory message section
            if (_isFetchingIntro)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_introductoryMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: _generateIntroMessageWithClickableQuestions(),
                      ),
                    ),
                    SizedBox(height: scrWidth*0.03,),
                    Text(
                      _responseMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: _responseMessage.startsWith('Error')
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            // Response message section
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: SingleChildScrollView(
            //       reverse: true,
            //       child: Text(
            //         _responseMessage,
            //         style: TextStyle(
            //           fontSize: 16,
            //           color: _responseMessage.startsWith('Error')
            //               ? Colors.red
            //               : Colors.black,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // Input field section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      String message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        sendMessageToChatPdf(message);
                        _messageController.clear(); // Clear text field
                      } else {
                        setState(() {
                          _responseMessage = 'Please enter a message.';
                        });
                      }
                    },
                    child: _isLoading
                        ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generate the introductory message with clickable numbers
  List<TextSpan> _generateIntroMessageWithClickableQuestions() {
    List<TextSpan> spans = [];
    RegExp questionPattern = RegExp(r'(\d\.\s+)(.*?)(?=\n|$)');
    Iterable<Match> matches = questionPattern.allMatches(_introductoryMessage);

    int lastEnd = 0;
    for (var match in matches) {
      spans.add(TextSpan(
        text: _introductoryMessage.substring(lastEnd, match.start), // Text before the question
        style: TextStyle(color: Colors.black),
      ));

      spans.add(TextSpan(
        text: match.group(1), // Question number (e.g., "1.")
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            int questionNumber = int.parse(match.group(1)!.trim().split('.')[0]);
            fetchAnswerForQuestionNumber(questionNumber); // Fetch answer for the clicked question
          },
      ));

      spans.add(TextSpan(
        text: match.group(2), // The question text
        style: TextStyle(color: Colors.black),
      ));

      lastEnd = match.end;
    }

    // Add remaining text after the last question
    spans.add(TextSpan(
      text: _introductoryMessage.substring(lastEnd),
      style: TextStyle(color: Colors.black),
    ));

    return spans;
  }
}


// Widget _buildEditForm() {
//   return Form(
//     key: _formKey,
//     child: ListView(
//       padding: const EdgeInsets.all(16.0),
//       children: [
//         // Title Header
//         Text(
//           "Edit Teacher Details",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.deepPurple.shade700,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 24),
//
//         // Name Field
//         _buildTextFieldCard(
//           label: "Name",
//           icon: Icons.person,
//           hint: "Enter teacher's name",
//           initialValue: name,
//           onChanged: (value) => name = value,
//         ),
//         const SizedBox(height: 16),
//
//         // Email Field
//         _buildTextFieldCard(
//           label: "Email",
//           icon: Icons.email,
//           hint: "Enter teacher's email",
//           initialValue: email,
//           onChanged: (value) => email = value,
//         ),
//         const SizedBox(height: 16),
//
//         // Password Field
//         _buildTextFieldCard(
//           label: "Password",
//           icon: Icons.lock,
//           hint: "Enter a secure password",
//           initialValue: password,
//           obscureText: true,
//           onChanged: (value) => password = value,
//         ),
//         const SizedBox(height: 24),
//
//         // Buttons
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   isEditing = false;
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 backgroundColor: Colors.grey.shade300,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Text(
//                 "Cancel",
//                 style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _saveTeacherDetails,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 backgroundColor: Colors.deepPurple,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 "Save",
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
// // Helper to build detail view item
// Widget _buildDetailItem(String title, String value) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         title,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//       const SizedBox(height: 8),
//       Text(
//         value.isNotEmpty ? value : "Not available",
//         style: const TextStyle(fontSize: 14),
//       ),
//       const Divider(),
//     ],
//   );
// }
//
// // Helper Method for Text Fields in Cards
// Widget _buildTextFieldCard({
//   required String label,
//   required IconData icon,
//   required String hint,
//   required String initialValue,
//   required ValueChanged<String> onChanged,
//   bool obscureText = false,
// }) {
//   return Card(
//     elevation: 4,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//       child: TextFormField(
//         initialValue: initialValue,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           prefixIcon: Icon(icon, color: Colors.deepPurple),
//           border: InputBorder.none,
//         ),
//         obscureText: obscureText,
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return "$label cannot be empty.";
//           }
//           return null;
//         },
//         onChanged: onChanged,
//       ),
//     ),
//   );
// }
// }