class FlashCard {
  final String id;  // 🔹 thêm id
  final String title;
  final String description;
  final List<Map<String, String>> terms; 
  final String category;

  FlashCard({
    required this.id,
    required this.title,
    required this.description,
    required this.terms,
    required this.category,
  });

  // fromJson
  factory FlashCard.fromJson(Map<String, dynamic> json) {
    var termsFromJson = json['terms'] as List;
    List<Map<String, String>> termsList = termsFromJson.map((term) {
      return {
        'term': term['term'] as String,
        'meaning': term['meaning'] as String
      };
    }).toList();

    return FlashCard(
      id: json['_id'] ?? "",  // 🔹 map từ MongoDB _id
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      category: json['category'] ?? "Tất cả",
      terms: termsList,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'terms': terms.map((term) {
        return {
          'term': term['term'],
          'meaning': term['meaning']
        };
      }).toList(),
    };
  }
}
