import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../api/translate_service.dart';

// Màn hình tạo Flashcard
class CreateFlashcardScreen extends StatefulWidget {
  final String? category;

  // ❌ KHÔNG dùng const ở đây
  CreateFlashcardScreen({Key? key, this.category}) : super(key: key);

  @override
  _CreateFlashcardScreenState createState() => _CreateFlashcardScreenState();
}

class _CreateFlashcardScreenState extends State<CreateFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<TextEditingController> _wordControllers = [];
  List<TextEditingController> _meaningControllers = [];
  List<List<String>> _suggestions = [];

  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _addTermField();
  }

  void _addTermField() {
    setState(() {
      _wordControllers.add(TextEditingController());
      _meaningControllers.add(TextEditingController());
      _suggestions.add([]); // 🔹 Thêm danh sách gợi ý rỗng
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _createFlashcard() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final title = _titleController.text;
      final description = _showDescription ? _descriptionController.text : "";
      final category = widget.category;
      List<Map<String, String>> terms = [];
      for (int i = 0; i < _wordControllers.length; i++) {
        terms.add({
          "term": _wordControllers[i].text,
          "meaning": _meaningControllers[i].text,
        });
      }

      debugPrint("📤 Sending data: $title - $description -  $category - $terms");

      final response = await apiService.createFlashcard(
        title: title,
        description: description,
        terms: terms,
        category: category ?? "Tất cả",
      );
      if (response == true) {
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi: API trả về không thành công")),
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi tạo flashcard: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FlashcardSettingsScreen()),
    );
  }

  Future<void> _fetchSuggestions(int index) async {
    final term = _wordControllers[index].text.trim();
    if (term.isEmpty) return;

    final results = await TranslateService.translateToVietnamese(term);
    setState(() {
      _suggestions[index] = results;
    });
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
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  controller: _titleController,
                  label: 'Tiêu đề',
                  validatorText: 'Vui lòng nhập tiêu đề',
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDescription = true;
                    });
                  },
                  child: !_showDescription
                      ? const Text(
                          "+ Mô tả",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      : const SizedBox.shrink(),
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
                          TextFormField(
                            controller: _meaningControllers[index],
                            onTap: () => _fetchSuggestions(index),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'ĐỊNH NGHĨA ${index + 1}',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Vui lòng nhập định nghĩa"
                                : null,
                          ),
                          if (_suggestions[index].isNotEmpty)
                            ..._suggestions[index].map((s) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _meaningControllers[index].text = s;
                                    _suggestions[index] = [];
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A70),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    s,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }).toList(),
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
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
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

  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
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
          Text(
            right,
            style: const TextStyle(color: Colors.blueAccent, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
