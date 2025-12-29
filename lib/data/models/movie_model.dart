class MovieModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? description;
  final String? category;
  final String? year;
  final String? rating;
  final DateTime createdAt;

  MovieModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.description,
    this.category,
    this.year,
    this.rating,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['imageUrl'] ?? json['image_url'] ?? json['poster'] ?? '';
    // Clean URL: remove whitespace and any quotes that might have been added by mistake
    String cleanedUrl = rawUrl.trim().replaceAll('"', '').replaceAll("'", "");

    return MovieModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? 'Untitled',
      imageUrl: cleanedUrl,
      description: json['description'] ?? json['overview'],
      category: json['category'] ?? json['genre'],
      year: json['year']?.toString() ?? json['release_date'],
      rating: json['rating']?.toString() ?? json['vote_average']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'year': year,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
