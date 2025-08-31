class Study {
  final String id;
  final String title;
  final String subtitle;
  final int wordCount;
  final String category;

  Study({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.wordCount,
    required this.category,
  });

  factory Study.fromJson(Map<String, dynamic> json) {
    return Study(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      wordCount: json['wordCount'],
      category: json['category'],
    );
  }
}
