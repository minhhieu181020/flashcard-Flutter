import 'package:flutter/material.dart';
import '../../models/flashcard.dart';

class FlashcardItem extends StatelessWidget {
  final FlashcardSet set;
  const FlashcardItem({super.key, required this.set});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.menu_book, color: Colors.blueAccent),
      title: Text(set.title, style: TextStyle(color: Colors.white)),
      subtitle: Text(
        "${set.subtitle} • ${set.wordCount} thuật ngữ",
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
      trailing: Icon(Icons.more_vert, color: Colors.white),
    );
  }
}
