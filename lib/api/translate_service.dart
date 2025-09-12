import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslateService {
  static const String _apiUrl = "https://api.mymemory.translated.net/get";

  static Future<List<String>> translateToVietnamese(String text) async {
    try {
      final response = await http.get(
        Uri.parse("$_apiUrl?q=$text&langpair=en|vi"),
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data["responseData"]["translatedText"];
        return [translatedText];
      } else {
        return [];
      }
    } catch (e) {
      print("⚠️ Translation error: $e");
      return [];
    }
  }
}
