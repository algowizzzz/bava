import 'package:flutter/material.dart';
import 'package:chatbot/services/languageTranslation/service.dart'; // Ensure this points to your TranslatorService

class TranslationPage extends StatefulWidget {
  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool _isLoading = false;

  // Available languages and their codes
  final Map<String, String> _languages = {
    'Malayalam': 'ml',
    'Hindi': 'hi',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
  };

  String _selectedLanguage = 'ml'; // Default selected language (Malayalam)

  // Function to handle translation
  void _translateText() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _translatedText = '';
    });

    String inputText = _textController.text;

    try {
      String translation =
      await TranslatorService.translate(inputText, _selectedLanguage);

      setState(() {
        _translatedText = translation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Language Translator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text to translate',
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Select Language:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  items: _languages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(entry.key),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _translateText,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Translate'),
            ),
            SizedBox(height: 16),
            if (_translatedText.isNotEmpty)
              Text(
                'Translation: $_translatedText',
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
