class CoordiModel {
  final String imageUrl;
  final String title;
  final String tags;
  final int likes;
  final int temperature;

  CoordiModel({
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.likes,
    required this.temperature,
  });

  factory CoordiModel.fromJson(Map<String, dynamic> json) {
    return CoordiModel(
      imageUrl: json['image_url'],
      title: json['title'],
      tags: json['tags'],
      likes: json['likes'],
      temperature: json['temperature'],
    );
  }
}
