import 'package:flutter/material.dart';
import '../../api/api_service.dart';

// Màn hình tạo Flashcard
class CreateFlashcardScreen extends StatefulWidget {
  @override
  _CreateFlashcardScreenState createState() => _CreateFlashcardScreenState();
}

class _CreateFlashcardScreenState extends State<CreateFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<TextEditingController> _wordControllers = [];
  List<TextEditingController> _meaningControllers = [];

  bool _showDescription = false; // Trạng thái ẩn/hiện mô tả
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _addTermField();
  }

  void _addTermField() {
    setState(() {
      _wordControllers.add(TextEditingController());
      _meaningControllers.add(TextEditingController());
    });
  }

  void _createFlashcard() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final description = _showDescription ? _descriptionController.text : "";

      List<Map<String, String>> terms = [];
      for (int i = 0; i < _wordControllers.length; i++) {
        terms.add({
          "term": _wordControllers[i].text,
          "meaning": _meaningControllers[i].text,
        });
      }

      final response = await apiService.createFlashcard(
        title: title,
        description: description,
        terms: terms,
      );

      if (response) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: Không thể tạo flashcard")),
        );
      }
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FlashcardSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A093F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A093F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "1/2",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _createFlashcard,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nhập Tiêu đề
                _buildInputField(
                  controller: _titleController,
                  label: 'Tiêu đề',
                  validatorText: 'Vui lòng nhập tiêu đề',
                ),
                const SizedBox(height: 12),

                // Nút thêm mô tả
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDescription = true;
                    });
                  },
                  child: !_showDescription
                      ? Text(
                          "+ Mô tả",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      : SizedBox.shrink(),
                ),
                if (_showDescription)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildInputField(
                      controller: _descriptionController,
                      label: 'Mô tả',
                      maxLines: 3,
                    ),
                  ),
                const SizedBox(height: 16),

                // Danh sách các block từ vựng
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _wordControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            controller: _wordControllers[index],
                            label: 'Thuật ngữ ${index + 1}',
                            validatorText: 'Vui lòng nhập từ vựng',
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _meaningControllers[index],
                            label: 'Định nghĩa ${index + 1}',
                            validatorText: 'Vui lòng nhập định nghĩa',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTermField,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? validatorText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
      validator: validatorText != null
          ? (value) => value == null || value.isEmpty ? validatorText : null
          : null,
      maxLines: maxLines,
    );
  }
}

// 🔹 Màn hình cài đặt
class FlashcardSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A093F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A093F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cài đặt tùy chọn",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingSection(
            title: "NGÔN NGỮ",
            children: [
              _buildSettingRow("Thuật ngữ", "Chọn ngôn ngữ"),
              _buildSettingRow("Định nghĩa", "Chọn ngôn ngữ"),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingSection(
            title: "GỢI Ý TỰ ĐỘNG",
            children: [
              SwitchListTile(
                value: true,
                onChanged: (_) {},
                title: const Text(
                  "Gợi ý tự động",
                  style: TextStyle(color: Colors.white),
                ),
                activeColor: Colors.blueAccent,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingSection(
            title: "QUYỀN RIÊNG TƯ",
            children: [
              _buildSettingRow("Ai có thể xem", "Mọi người"),
              _buildSettingRow("Ai có thể sửa", "Chỉ tôi"),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: const Text(
              "Xóa học phần",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C54),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(color: Colors.white, fontSize: 15)),
          Text(right,
              style: const TextStyle(color: Colors.blueAccent, fontSize: 15)),
        ],
      ),
    );
  }
}
