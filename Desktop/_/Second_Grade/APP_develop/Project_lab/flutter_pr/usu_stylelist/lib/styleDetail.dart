import 'package:flutter/material.dart';

class CoordDetailPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<dynamic> tags;
  final String temperature;
  final String description;
  final String weather;
  final String username;
  final String tier;
  final int rank;

  const CoordDetailPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.description,
    required this.temperature,
    required this.weather,
    required this.username,
    required this.tier,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('코디 상세 정보'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView(
        children: [
          // 이미지
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image, size: 60)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          // 본문 내용
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👇 날씨 배너 추가
                if (weather.isNotEmpty || temperature.isNotEmpty)
                  weatherBanner(),

                // 타이틀
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 태그
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                const Divider(),

                // 설명
                Text(
                  description.isNotEmpty
                      ? description
                      : '설명이 제공되지 않았습니다.',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                // 작성자 휘장 카드
                uploaderBadge(
                  username: username,
                  tier: tier,
                  rank: rank,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 날씨 배너 위젯
  Widget weatherBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (weather.contains("맑음"))
            const Icon(Icons.wb_sunny, color: Colors.orange, size: 28)
          else if (weather.contains("흐림"))
            const Icon(Icons.cloud, color: Colors.grey, size: 28)
          else if (weather.contains("비"))
            const Icon(Icons.umbrella, color: Colors.blue, size: 28)
          else
            const Icon(Icons.wb_cloudy, size: 28),

          const SizedBox(width: 8),
          Text(
            "$weather / $temperature°C",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 작성자 휘장 위젯
  Widget uploaderBadge({
    required String username,
    required String tier,
    required int rank,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 + 휘장
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue[50],
                child: Icon(Icons.person, color: Colors.grey[700], size: 32),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(Icons.shield, size: 16, color: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // 정보 텍스트
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.diamond, size: 16, color: getTierColor(tier)),
                  Text(
                    ' $tier 티어',
                    style: TextStyle(
                      color: getTierColor(tier),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.emoji_events,
                      size: 16, color: Colors.amber),
                  Text(' 전체 사용자 중 $rank위'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 티어 색상 함수
  Color getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return Colors.brown;
      case 'silver':
        return Colors.grey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.blue;
      case 'diamond':
        return Colors.teal;
      default:
        return Colors.black87;
    }
  }
}
