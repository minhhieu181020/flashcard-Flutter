
import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslateService {
  static const String _url = "https://libretranslate.de/translate";

  static Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "q": text,
        "source": sourceLang,
        "target": targetLang,
        "format": "text"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["translatedText"];
    } else {
      throw Exception("Translation failed: ${response.statusCode}");
    }
  }
}
