import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../api/api_service.dart';
import '../../models/flash_card.dart';
import 'create_flashcard_sceen.dart'; // adjust path nếu file ở chỗ khác

class FlashCardScreen extends StatefulWidget {
  final String studyId;
  final String studyTitle;

  const FlashCardScreen({
    super.key,
    required this.studyId,
    required this.studyTitle,
  });

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen>
    with TickerProviderStateMixin {
  final ApiService apiService = ApiService();
  Future<List<FlashCard>>? flashCardList;
  final FlutterTts flutterTts = FlutterTts();

  // Biến để điều khiển hiệu ứng lật
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  // Biến kiểm tra trạng thái lật của flashcard
  bool isFlipped = false;

  @override
  void initState() {
    super.initState();
    flashCardList = apiService.fetchFlashCards(widget.studyTitle);

    // Tạo AnimationController và Tween cho hiệu ứng lật 360 độ
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Khởi tạo _flipAnimation với giá trị ban đầu và cuối (lật 360 độ)
    _flipAnimation = Tween<double>(begin: 0.0, end: 6.2832).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Hủy controller khi không còn sử dụng
    super.dispose();
  }

  Future<void> _speak(String word) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.speak(word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A093F),
      appBar: AppBar(
        title: Text(
          widget.studyTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A093F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: FutureBuilder<List<FlashCard>>(
        future: flashCardList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Lỗi: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Không có từ vựng",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final flashcards = snapshot.data!;
            return Column(
              children: [
                const SizedBox(height: 10),
                // Swiper ở trên
                SizedBox(
                  height: 260, // Chiều cao cố định cho swiper
                  child: _buildFlashcardSwiper(flashcards),
                ),
                const Divider(color: Colors.white24, thickness: 1),
                // ListView ở dưới
                Expanded(child: _buildFlashcardTerms(flashcards)),
              ],
            );
          }
        },
      ),
    );
  }

  // Gọi khi nhấn nút 3 chấm
  Future<void> _showOptions(BuildContext context) async {
    try {
      // Lấy danh sách flashcards hiện có từ Future lưu trong state
      final flashcards = await (flashCardList ?? Future.value(<FlashCard>[]));

      if (flashcards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không có flashcard để chỉnh sửa")),
        );
        return;
      }

      // Chọn flashcard muốn chỉnh sửa (ở đây mình lấy flashcards.first theo logic hiện tại)
      final flashcard = flashcards.first;

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text("Chỉnh sửa"),
                  onTap: () {
                    Navigator.pop(ctx); // đóng bottomsheet

                    // Chuyển sang màn CreateFlashcardScreen và truyền dữ liệu flashcard
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateFlashcardScreen(
                          isEditing: true,
                          flashcard: flashcard,
                          category: flashcard.category, // tuỳ cần truyền thêm
                        ),
                      ),
                    ).then((updated) {
                      // Nếu update thành công (CreateFlashcardScreen có pop(true)), reload list
                      if (updated == true) {
                        setState(() {
                          flashCardList = apiService.fetchFlashCards(
                            widget.studyTitle,
                          );
                        });
                      }
                    });
                  },
                ),
                ListTile(
                  
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Xoá"),
                  
                  onTap: () async {
                    print(widget.studyTitle);
                    Navigator.pop(ctx);

                    try {
                      bool result = await apiService.deleteStudyByTitle(
                        widget.studyTitle,
                        
                      );

                      if (result) {
                        if (mounted) {
                          Navigator.pop(context); // Quay lại màn trước
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Xoá học phần thành công"),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Xóa thất bại: $e")),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Nếu Future chưa sẵn hoặc có lỗi kết nối
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // Hiển thị Flashcard trong Swiper
  // Thay đổi phần _buildFlashcardSwiper:
  Widget _buildFlashcardSwiper(List<FlashCard> flashcards) {
    // Gộp tất cả terms từ tất cả flashcards
    final allTerms = flashcards.expand((card) => card.terms).toList();

    return Swiper(
      itemCount: allTerms.length, // Mỗi term là 1 slide
      itemBuilder: (context, index) {
        final term = allTerms[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              isFlipped = !isFlipped;
              if (isFlipped) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            });
          },
          child: Card(
            color: const Color(0xFF1C1B5A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(_flipAnimation.value),
                    child: isFlipped
                        ? _buildBackSideTerm(term) // Mặt sau chỉ meaning
                        : _buildFrontSideTerm(term), // Mặt trước chỉ term
                  );
                },
              ),
            ),
          ),
        );
      },
      pagination: const SwiperPagination(
        builder: DotSwiperPaginationBuilder(color: Colors.white54),
      ),
      control: const SwiperControl(color: Colors.white),
      scrollDirection: Axis.horizontal,
    );
  }

  // Mặt trước của 1 thẻ: hiển thị term
  Widget _buildFrontSideTerm(Map<String, dynamic> term) {
    return Center(
      key: const ValueKey(1),
      child: Text(
        term['term'] ?? '',
        style: const TextStyle(fontSize: 22, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Mặt sau của 1 thẻ: hiển thị meaning
  Widget _buildBackSideTerm(Map<String, dynamic> term) {
    return Center(
      key: const ValueKey(2),
      child: Text(
        term['meaning'] ?? '',
        style: const TextStyle(fontSize: 20, color: Colors.white70),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Hiển thị các terms trong ListView (phần bên dưới)
  // Sửa lại phần ListView
  Widget _buildFlashcardTerms(List<FlashCard> flashcards) {
    final card = flashcards.first; // giữ nguyên logic của bạn

    return ListView.builder(
      itemCount: card.terms.length,
      itemBuilder: (context, index) {
        final term = card.terms[index];
        final example = term['example'] ?? '';

        return Card(
          color: const Color(0xFF1C1B5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Term + Icon loa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        term['term'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      onPressed: () {
                        _speak(term['term'] ?? '');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Meaning
                Text(
                  term['meaning'] ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                // Example nếu có
                if (example.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    example,
                    style: const TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
