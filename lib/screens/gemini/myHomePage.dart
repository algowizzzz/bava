import 'package:chatbot/services/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../services/message.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  final ThemeMode currentTheme = ThemeMode.light; // Example theme mode
  final VoidCallback toggleTheme = () {};

  String formatText(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'),
            (match) => '${match[1]}'.toUpperCase())
        .replaceAll('*', '\n• ');
  }
  // Function to call Gemini API
  callGeminiModel() async {
    try {
      if (_controller.text.isNotEmpty) {
        setState(() {
          _messages.add(Message(text: _controller.text, isUser: true));
          _isLoading = true;
        });
        String? apiKey = dotenv.env['GOOGLE_API_KEY'];
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('API Key is missing. Make sure it is defined in the .env file.');
        }

        final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,  // Safely using the API key after null check
        );

        final prompt = _controller.text.trim();
        final content = [Content.text(prompt)];

        final response = await model.generateContent(content);

        setState(() {
          // Safely handle the response text
          if (response.text != null && response.text!.isNotEmpty) {
            // Format the response text (e.g., make certain keywords bold)
            String formattedText = formatText(response.text!);

            _messages.add(Message(text: formattedText, isUser: false));
          } else {
            _messages.add(Message(text: 'No response from the model', isUser: false));
          }
          _isLoading = false;
        });

        _controller.clear();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error calling Gemini Model: $e'); // For debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);

    return  Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: 10),
                Text(
                  'ChatGPT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              child: (currentTheme == ThemeMode.dark)
                  ? Icon(Icons.light_mode, color: Colors.white)
                  : Icon(Icons.dark_mode, color: Colors.white),
              onTap: toggleTheme,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF9C27B0), Color(0xFFD1C4E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Display chat messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                    child: Align(
                      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: message.isUser
                                ? [Colors.purpleAccent, Colors.deepPurple]
                                : [Colors.white, Colors.grey.shade300],
                          ),
                          borderRadius: message.isUser
                              ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          )
                              : const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // User input field and send button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    _isLoading
                        ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {}, // callGeminiModel function
                        child: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          radius: 20,
                          child: Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
