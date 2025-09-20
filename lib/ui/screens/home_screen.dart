import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../models/study.dart';
import '../screens/flash_card_screen.dart';
import '../screens/create_flashcard_sceen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  Future<List<Study>>? studyList;

  final List<String> categories = ["Tất cả", "cambridge 10", "cambridge 11"];
  String selectedCategory = "Tất cả";

  @override
  void initState() {
    super.initState();
    _reloadStudyList();
  }

  void _reloadStudyList() {
    setState(() {
      studyList = apiService.fetchStudyList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C2C), // nền tối như ảnh
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0C2C),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text(
          "ielts cambridge",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              // 👉 mở màn hình thêm flashcard và reload khi quay lại
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateFlashcardScreen(
                    category: selectedCategory == "Tất cả"
                        ? null
                        : selectedCategory,
                  ),
                ),
              );
              _reloadStudyList();
            },
          ),
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 12),
          const Icon(Icons.more_vert, color: Colors.white),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.blueGrey,
                  onSelected: (_) {
                    setState(() => selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Gần đây",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          // Danh sách API
          Expanded(
            child: FutureBuilder<List<Study>>(
              future: studyList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Lỗi: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Không có dữ liệu",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final data = snapshot.data!;
                final filteredData = selectedCategory == "Tất cả"
                    ? data
                    : data.where((s) => s.category == selectedCategory).toList();

                // ✅ Nếu không có học phần nào
                if (filteredData.isEmpty) {
                  return Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateFlashcardScreen(
                              category: selectedCategory == "Tất cả"
                                  ? null
                                  : selectedCategory,
                            ),
                          ),
                        );
                        _reloadStudyList();
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Thêm học phần",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                }

                // ✅ Có dữ liệu thì hiển thị danh sách
                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final study = filteredData[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.folder,
                        color: Colors.lightBlueAccent,
                      ),
                      title: Text(
                        study.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "${study.subtitle} • ${study.category}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        "${study.wordCount} từ",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () async {
                        // 👉 mở flashcard screen và reload khi quay lại
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashCardScreen(
                              studyId: study.id,
                              studyTitle: study.title,
                            ),
                          ),
                        );
                        _reloadStudyList();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
