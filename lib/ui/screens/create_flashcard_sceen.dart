import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../models/flash_card.dart';  // Model FlashCard

class CreateFlashcardScreen extends StatefulWidget {
  @override
  _CreateFlashcardScreenState createState() => _CreateFlashcardScreenState();
}

class _CreateFlashcardScreenState extends State<CreateFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ApiService apiService = ApiService();

  void _createFlashcard() async {
  if (_formKey.currentState!.validate()) {
    final title = _titleController.text;
    final description = _descriptionController.text;

    // Tạo danh sách terms từ các controllers
    List<Map<String, String>> terms = [
      {
        "term": _wordController.text,   // Giá trị term
        "meaning": _meaningController.text  // Giá trị meaning
      },
    ];
    print('Dữ liệu gửi đi:');
    print('Title: $title');
    print('Description: $description');
    print('Terms: $terms');

    // Nếu bạn muốn hỗ trợ thêm nhiều term-meaning, bạn có thể dùng cách sau
    // terms.add({"term": anotherTermController.text, "meaning": anotherMeaningController.text});
    
    final response = await apiService.createFlashcard(
      title: title,
      description: description,
      terms: terms,  // Gửi danh sách terms tới API
    );

    if (response) {
      Navigator.pop(context); // Quay lại màn hình trước
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: Không thể tạo flashcard")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo Flashcard"),
        backgroundColor: const Color(0xFF0A093F),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Các trường nhập liệu
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(labelText: 'Từ vựng'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập từ vựng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _meaningController,
                decoration: const InputDecoration(labelText: 'Định nghĩa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập định nghĩa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
             ElevatedButton(
  onPressed: _createFlashcard,
  child: const Text('Tạo Flashcard'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1C1B5A),  // Thay 'primary' bằng 'backgroundColor'
    padding: const EdgeInsets.symmetric(vertical: 15),
  ),
)

            ],
          ),
        ),
      ),
    );
  }
}
