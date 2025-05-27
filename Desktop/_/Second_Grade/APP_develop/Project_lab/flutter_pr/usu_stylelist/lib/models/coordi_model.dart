class CoordiModel {
  final String imageUrl;
  final String title;
  final String tags;
  final int likes;
  final int temperature;

  // 🆕 작성자 정보
  final String username;
  final String tier;
  final int rank;

  CoordiModel({
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.likes,
    required this.temperature,
    required this.username,
    required this.tier,
    required this.rank,
  });

  factory CoordiModel.fromJson(Map<String, dynamic> json) {
    return CoordiModel(
      imageUrl: json['image_url'],
      title: json['title'],
      tags: json['tags'],
      likes: json['likes'],
      temperature: json['temperature'],

      // 🆕 사용자 정보 파싱
      username: json['username'] ?? '익명',
      tier: json['tier'] ?? 'Bronze',
      rank: json['rank'] ?? 9999,
    );
  }
}
