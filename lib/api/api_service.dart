import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/study.dart';
import '../models/flash_card.dart';
final String baseUrl = "https://flashcard-backend-0dwg.onrender.com";
class ApiService {
  

  Future<List<Study>> fetchStudyList() async {
    final response = await http.get(Uri.parse("$baseUrl/listStudy"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Study.fromJson(item)).toList();
    } else {
      // Nên throw exception thay vì không trả về gì
      throw Exception("Failed to load study list: ${response.statusCode}");
    }
  }
Future<List<FlashCard>> fetchFlashCards(String title) async {
  final response = await http.post(
    Uri.parse("$baseUrl/listFlashCard"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"title": title}), // gửi id học phần
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => FlashCard.fromJson(json)).toList();
  } else {
    throw Exception("Failed to load flashcards");
  }
}

 // Thêm flashcard mới (POST)
 Future<bool> createFlashcard({
  required String title,
  required String description,
  required List<Map<String, String>> terms, // Sử dụng terms thay vì word và meaning
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/createFlashcard"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "title": title,
      "description": description,
      "terms": terms, // Gửi terms dưới dạng mảng
    }),
  );

  if (response.statusCode == 201) {
    return true; // Flashcard đã được tạo thành công
  } else {
    throw Exception("Failed to create flashcard: ${response.statusCode}");
  }
}
}

