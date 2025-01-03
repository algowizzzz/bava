import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorService {
  static const String _apiKey = 'AIzaSyDdIi-FPKlkjA5bRaHgb_QB4ZBLxLLFVWU';
  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';
  static Future<String> translate(String text, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': [text],
          'target': targetLanguage,
          'key': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to translate. Response: ${response.body}');
      }
    } catch (e) {
      print('Translation Error: $e');
      throw Exception('Translation error occurred: $e');
    }
  }
}
