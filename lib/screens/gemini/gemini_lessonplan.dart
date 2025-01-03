import 'package:chatbot/main.dart';
import 'package:chatbot/model/historyModel.dart';
import 'package:chatbot/screens/homePage/functions/pdf_generator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/topicModel.dart';

class geminiLessonPlan extends ConsumerStatefulWidget {
  final String prompt;
  final String validationPrompt;
  final String className;
  final String subject;
  final String topic;
  final Function(String) onValidationError;

  const geminiLessonPlan({
    required this.prompt,
    required this.validationPrompt,
    required this.className,
    required this.topic,
    required this.subject,
    required this.onValidationError,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<geminiLessonPlan> createState() => _GeminiLessonPlanState();
}

class _GeminiLessonPlanState extends ConsumerState<geminiLessonPlan> {
  String? _lessonPlanResponse;
  String? _chatResponse;
  String? _pptResponse;
  String? _handoutResponse;
  String? _contextBuilderResponse;
  String? _applicationInRealLifeResponse;
  String? _historyDocumentId;
  bool _isLoading = false;
  bool _isGeneratingPPT = false;
  bool _isGeneratingHandout = false;
  bool _isGeneratingcontextBuilder= false;
  bool _isGeneratingApplicationInRealLife = false;
  bool _isPPTButtonDisabled = false;
  bool _isHandoutButtonDisabled = false;
  bool _isApplicationInRealLifeButtonDisabled= false;
  bool _iscontextBuilderButtonDisabled= false;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    validateTopic();
  }
  String formatText(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => '${match[1]}'.toUpperCase())
        .replaceAll('*', '\n• ');
  }
  Future<void> validateTopic() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final content = [Content.text(widget.validationPrompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        if (response.text!.toLowerCase().startsWith('yes')) {
          await callGeminiModel();
        } else {
          widget.onValidationError('Error: The topic "${widget.topic}" is not relevant to the subject.');
        }
      } else {
        widget.onValidationError('No response from the model for validation.');
      }
    } catch (e) {
      widget.onValidationError('Error validating topic with Gemini: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Widget buildFixedHeightCard(String response) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5.0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: scrWidth*1.6,
          width: scrWidth*0.7,// Fixed height for consistency
          padding: EdgeInsets.all(scrWidth*0.02),
          child: Text(
            response,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }
  Future<void> callGeminiModel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final content = [Content.text(widget.prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _lessonPlanResponse = formatText(response.text ?? 'No response from the model');
        _chatResponse = null;
        _pptResponse = null;
        _handoutResponse = null;
        _contextBuilderResponse = null;
        _applicationInRealLifeResponse = null;
      });

      await saveClassHistory(response.text ?? 'No response from the model');
    } catch (e) {
      widget.onValidationError('Error generating lesson plan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> saveClassHistory(String lessonPlan) async {
    try {
      // Reference to the 'history' collection
      CollectionReference classHistoryCollection = FirebaseFirestore.instance.collection('history');
      DocumentReference historyDoc;
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      // Query to find the history document with the matching className and subject
      QuerySnapshot historySnapshot = await classHistoryCollection
          .where('className', isEqualTo: widget.className)
          .where('subject', isEqualTo: widget.subject)
          .where('userUid', isEqualTo: currentUserUid)
          .limit(1) // To get at most one matching document
          .get();

      // If a matching history document is found, use it; otherwise, create a new one
      if (historySnapshot.docs.isNotEmpty) {
        // Use the first matching document
        historyDoc = historySnapshot.docs.first.reference;

        // Update the 'topics' array in the existing history document
        // Ensure you add the new topic to the existing list
        await historyDoc.update({
          'topics': FieldValue.arrayUnion([widget.topic]), // Add new topic to the list
        });

        print('Topic added to existing history document');
      } else {
        // Create a new history document if no matching one is found
        historyDoc = classHistoryCollection.doc();
        _historyDocumentId = historyDoc.id;

        // Save the new history document with the initial topic in the list
        await historyDoc.set(
          HistoryModel(
            history_id: historyDoc.id,
            date: DateTime.now(),
            topic: [widget.topic].toString(), // Initialize with a list containing the current topic
            className: widget.className,
            subject: widget.subject,
            userUid: currentUserUid,
          ).toMap(),
        );

        print('New history document created with topic');
      }

      CollectionReference topicCollection = historyDoc.collection('topics');
      String topicId = widget.topic; // Use the topic name as the document ID

      DocumentReference topicDoc = topicCollection.doc(topicId); // Topic document reference

      DocumentSnapshot topicSnapshot = await topicDoc.get();
      if (topicSnapshot.exists) {
        print('Topic document exists, updating data...');
        await topicDoc.update({
          'lessonPlan': _lessonPlanResponse ?? 'No response',
          'ppt': _pptResponse ?? 'No response',
          'handout': _handoutResponse ?? 'No response',
          'contextBuilder': _contextBuilderResponse ?? 'No response',
          'applicationsInRealLife': _applicationInRealLifeResponse ?? 'No response',
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        print('Topic document does not exist, creating a new one...');
        // If the topic document does not exist, create a new one
        await topicDoc.set(
          TopicModel(
            id: topicId,
            topic: widget.topic,
            lessonPlan: lessonPlan,
            ppt: _pptResponse ?? 'No response',
            handout: _handoutResponse ?? 'No response',
            contextBuilder: _contextBuilderResponse ?? 'No response',
            applicationsInRealLife: _applicationInRealLifeResponse ?? 'No response',
            createdAt: DateTime.now(),
          ).toMap(),
        );
      }
    } catch (e) {
      // Enhanced error handling: Catch specific errors and provide meaningful feedback
      if (e is FirebaseException) {
        widget.onValidationError('Firestore Error: ${e.message}');
      } else {
        widget.onValidationError('Error saving class history: $e');
      }
    }
  }
  Future<void> generateApplicationInRealLife() async {
    setState(() {
      _isGeneratingApplicationInRealLife = true;
      _isApplicationInRealLifeButtonDisabled = true;
    });

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final content = [
        Content.text('Act as a qualified CBSE school Teacher from India of ${widget.className} who specializes in ${widget.subject}teaching. Generate a list of real-life applications for the topic: ${widget.topic}')
      ];
      final response = await model.generateContent(content);

      setState(() {
        _applicationInRealLifeResponse = formatText(response.text ?? 'No response from the model');
      });

      // Save the history after generating the real-life application
      await saveClassHistory(_applicationInRealLifeResponse!);

    } catch (e) {
      showErrorDialog('Error generating application in real life: $e');
    } finally {
      setState(() {
        _isGeneratingApplicationInRealLife = false;
        _isApplicationInRealLifeButtonDisabled = false;
      });
    }
  }
  Future<void> generateContextBuilder() async {
    setState(() {
      _isGeneratingcontextBuilder = true;
      _isApplicationInRealLifeButtonDisabled = true;
    });

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final content = [Content.text('Act as a qualified CBSE school Teacher from India of Class ${widget.className} who specializes in teaching ${widget.subject} and generate a Context Builder that introduces the topic to students of the age (${widget.className} + 4) for the topic ${widget.topic}')];
      final response = await model.generateContent(content);

      setState(() {
        _contextBuilderResponse = formatText(response.text ?? 'No response from the model');
      });

      // Save the history after generating the context builder
      await saveClassHistory(_contextBuilderResponse!);

    } catch (e) {
      showErrorDialog('Error generating context builder: $e');
    } finally {
      setState(() {
        _isGeneratingcontextBuilder = false;
        _isApplicationInRealLifeButtonDisabled = false;
      });
    }
  }
  Future<void> generatePPT() async {
    setState(() {
      _isGeneratingPPT = true;
      _isPPTButtonDisabled = true;
    });

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final content = [Content.text('Act as a qualified CBSE school Teacher from India of  ${widget.className} specializes in ${widget.subject} teaching and generate a slide by slide presentation for teaching the topic: ${widget.topic}')];
      final response = await model.generateContent(content);

      setState(() {
        print(response.text);
        _pptResponse = formatText(response.text ?? 'No response from the model');

      });

      // Save the history after generating the PPT
      await saveClassHistory(_lessonPlanResponse ?? 'No response');

    } catch (e) {
      showErrorDialog('Error generating PPT: $e');
    } finally {
      setState(() {
        _isGeneratingPPT = false;
        _isPPTButtonDisabled = false;
      });
    }
  }
  void showHandoutDialog() {
    String questionType = '';
    String questionCount = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generate Handout & Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Type of Questions'),
                onChanged: (value) {
                  questionType = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Number of Questions'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  questionCount = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate inputs
                if (questionType.isNotEmpty && questionCount.isNotEmpty) {
                  int count = int.tryParse(questionCount) ?? 0;
                  if (count > 0) {
                    // Call method to generate the handout with the user's input
                    generateHandout(questionType, count);
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    showErrorDialog('Please enter a valid number of questions.');
                  }
                } else {
                  showErrorDialog('Please fill in all fields.');
                }
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }
  Future<void> generateHandout(String questionType, int count) async {
    setState(() {
      _isGeneratingHandout = true;
      _isHandoutButtonDisabled = true;
    });

    try {
      String? apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing. Make sure it is defined in the .env file.');
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final content = [
        Content.text('Act as qualified CBSE school teacher from India of class ${widget.className} Generate a handout for on ${widget.subject} more than 200 words on the ${widget.topic}.'
            'Include $count questions of type: $questionType.')
      ];
      final response = await model.generateContent(content);

      setState(() {
        _handoutResponse = formatText(response.text ?? 'No response from the model');
      });

      // Save the history after generating the handout
      await saveClassHistory(_lessonPlanResponse ?? 'No response');

    } catch (e) {
      showErrorDialog('Error generating handout: $e');
    } finally {
      setState(() {
        _isGeneratingHandout = false;
        _isHandoutButtonDisabled = false;
      });
    }
  }
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
  Future<void> handleChatSubmit() async {
    String userMessage = _chatController.text.trim();

    if (userMessage.isNotEmpty) {
      setState(() {
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
        });
      } catch (e) {
        // Error handling
        setState(() {
          _chatResponse = 'Error generating response: $e';
        });
      }

      // Clear the input field after submission
      _chatController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Teacher Assistant'),
        backgroundColor: Colors.purple,
        elevation: 8.0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFFBA68C8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _lessonPlanResponse != null
                    ? SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_isGeneratingPPT ||
                          _isGeneratingHandout ||
                          _isGeneratingcontextBuilder ||
                          _isGeneratingApplicationInRealLife)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      // Application in Real Life Response
                      if (_applicationInRealLifeResponse != null)
                        buildFixedHeightCard(_applicationInRealLifeResponse!),

                      // Context Builder Response
                      if (_contextBuilderResponse != null)
                        buildFixedHeightCard(_contextBuilderResponse!),

                      // Handout Response
                      if (_handoutResponse != null)
                        buildFixedHeightCard(_handoutResponse!),

                      // PPT Response
                      if (_pptResponse != null)
                        buildFixedHeightCard(_pptResponse!),

                      // Lesson Plan Response
                      buildFixedHeightCard(_lessonPlanResponse!),

                      // Chat Response
                      if (_chatResponse != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Card(
                            elevation: 5.0,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _chatResponse!,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                  if (_chatResponse!
                                      .toLowerCase()
                                      .contains('error'))
                                    Text(
                                      'Please try again.',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.red),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
                    : const Center(child: Text('No lesson plan generated yet.')),
              ),
            ),

            // Chat Input Area and Buttons for generating PPT and Handout remain the same
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      handleChatSubmit();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {

                      String getLatestGeneratedContent() {
                        // Initialize default content in case no content is available
                        String latestContent = 'No content available';

                        // Check each response in priority order and return the first non-null one
                        if (_applicationInRealLifeResponse != null) {
                          return _applicationInRealLifeResponse.toString();
                        } else if (_contextBuilderResponse != null) {
                          return _contextBuilderResponse.toString();
                        } else if (_handoutResponse != null) {
                          return _handoutResponse.toString();
                        } else if (_pptResponse != null) {
                          return _pptResponse.toString();
                        } else if (_lessonPlanResponse != null) {
                          return _lessonPlanResponse.toString();
                        }

                        return latestContent;
                      }



                      // Navigate to PdfGeneratorScreen with the latest generated content
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfGeneratorScreen(
                            content:getLatestGeneratedContent(),
                          ),
                        ),
                      );
                    },
                    child:Text(
                     _handoutResponse==null&& _pptResponse != null ? 'Generate PPT' : 'Download PDF',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading || _isPPTButtonDisabled ? null : generatePPT,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPPTButtonDisabled ? Colors.grey : Colors.purple, // Change color based on state
                    ),
                    child: const Text('Generate Presentation',style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading || _isHandoutButtonDisabled ? null : showHandoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isHandoutButtonDisabled ? Colors.grey : Colors.purple, // Change color based on state
                    ),
                    child: const Text('Generate Handout & Assignment',style:TextStyle(
                      color: Colors.white
                    ),),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading || _iscontextBuilderButtonDisabled ? null : generateContextBuilder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _iscontextBuilderButtonDisabled ? Colors.grey : Colors.purple, // Change color based on state
                    ),
                    child: const Text('Generate Context Builder',style:TextStyle(
                        color: Colors.white
                    ),),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading || _isApplicationInRealLifeButtonDisabled ? null : generateApplicationInRealLife,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isApplicationInRealLifeButtonDisabled? Colors.grey : Colors.purple, // Change color based on state
                    ),
                    child: const Text('Generate Application in Real LIfe',style:TextStyle(
                        color: Colors.white
                    ),),
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
