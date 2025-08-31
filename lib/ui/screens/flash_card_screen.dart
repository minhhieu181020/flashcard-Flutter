import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../api/api_service.dart';
import '../../models/flash_card.dart';

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

class _FlashCardScreenState extends State<FlashCardScreen> with TickerProviderStateMixin {
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
          style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A093F),
        elevation: 0,
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

  // Hiển thị Flashcard trong Swiper
  Widget _buildFlashcardSwiper(List<FlashCard> flashcards) {
    return Swiper(
      itemCount: flashcards.length,
      itemBuilder: (context, index) {
        final card = flashcards[index];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              isFlipped = !isFlipped;  // Lật mặt khi bấm vào
              if (isFlipped) {
                _animationController.forward();  // Bắt đầu hiệu ứng lật
              } else {
                _animationController.reverse();  // Quay lại hiệu ứng ban đầu
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
                        ? _buildBackSide(card)  // Mặt sau hiển thị meaning
                        : _buildFrontSide(card),  // Mặt trước hiển thị term
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
      scrollDirection: Axis.horizontal, // Trượt ngang
    );
  }

  // Mặt trước của thẻ (hiển thị term)
  Widget _buildFrontSide(FlashCard card) {
    return Column(
      key: ValueKey(1), // Đảm bảo AnimatedSwitcher hoạt động chính xác
      children: [
        Column(
          children: card.terms.map<Widget>((term) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    "${term['term']}: ",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Mặt sau của thẻ (hiển thị meaning)
  Widget _buildBackSide(FlashCard card) {
    return Column(
      key: ValueKey(2), // Đảm bảo AnimatedSwitcher hoạt động chính xác
      children: [
        Column(
          children: card.terms.map<Widget>((term) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
    
                  Text(
                    "${term['meaning']}", // Hiển thị meaning
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Hiển thị các terms trong ListView (phần bên dưới)
  Widget _buildFlashcardTerms(List<FlashCard> flashcards) {
    final card = flashcards.first;  // Lấy flashcard đầu tiên hoặc nếu có nhiều flashcards, bạn có thể thay đổi theo nhu cầu

    return ListView.builder(
      itemCount: card.terms.length,
      itemBuilder: (context, index) {
        final term = card.terms[index];

        return Card(
          color: const Color(0xFF1C1B5A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Hiển thị term và meaning
                Expanded(
                  child: Text(
                    "${term['term']}: ${term['meaning']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
