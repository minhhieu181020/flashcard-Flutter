class FlashCard {
  final String title;
  final String description;
  final List<Map<String, String>> terms; // Danh sách các term-meaning pairs

  FlashCard({
    required this.title,
    required this.description,
    required this.terms,
  });

  // Tạo phương thức fromJson để chuyển từ JSON thành đối tượng
  factory FlashCard.fromJson(Map<String, dynamic> json) {
    var termsFromJson = json['terms'] as List;
    List<Map<String, String>> termsList = termsFromJson.map((term) {
      return {
        'term': term['term'] as String,
        'meaning': term['meaning'] as String
      };
    }).toList();

    return FlashCard(
      title: json['title'],
      description: json['description'],
      terms: termsList,  // Chuyển đổi terms thành List<Map<String, String>>
    );
  }

  // Tạo phương thức toJson để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'terms': terms.map((term) {
        return {
          'term': term['term'],
          'meaning': term['meaning']
        };
      }).toList(),
    };
  }
}
