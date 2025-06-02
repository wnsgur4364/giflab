import 'package:flutter/material.dart';

class CoordDetailPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<dynamic> tags;
  final String temperatureMin;
  final String temperatureMax;
  final String description;
  final String weather;
  final String username;
  final String tier;
  final int rank;
  final String emojiUrl;
  final String top;
  final String bottom;
  final String outer;
  final String shoes;
  final String etc;

  const CoordDetailPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.description,
    required this.weather,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.username,
    required this.tier,
    required this.rank,
    required this.emojiUrl,
    required this.top,
    required this.bottom,
    required this.outer,
    required this.shoes,
    required this.etc,
  });
  

  @override
  Widget build(BuildContext context) {
    print('상의: $top, 하의: $bottom, 아우터: $outer, 신발: $shoes, 기타: $etc');

    return Scaffold(
      appBar: AppBar(
        title: const Text('코디 상세 정보'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image, size: 60)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                weatherBanner(),
                //const SizedBox(height: 2),
                uploaderBadge(username: username, tier: tier, rank: rank),
                
                Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      backgroundColor: Colors.grey[200],
                    );
                  }).toList(),
                ),
                const Divider(),
                Text(
                  description.isNotEmpty
                      ? description
                      : '설명이 제공되지 않았습니다.',
                  style: const TextStyle(fontSize: 16),
                ),
                
                const SizedBox(height: 20),
                buildClothingInfo("상의", top),
                buildClothingInfo("하의", bottom),
                buildClothingInfo("아우터", outer),
                buildClothingInfo("신발", shoes),
                buildClothingInfo("기타", etc),
                const SizedBox(height: 20),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget weatherBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.thermostat, color: Colors.redAccent),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              "$weather 최저 $temperatureMin°C / 최고 $temperatureMax°C",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          if (emojiUrl.isNotEmpty)
            Image.network(
              emojiUrl,
              
              height: 80,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
        ],
      ),
    );
  }

  Widget buildClothingInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• $label: ",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "정보 없음",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget uploaderBadge({
    required String username,
    required String tier,
    required int rank,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            child: Icon(Icons.person, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  Icon(Icons.diamond, size: 16, color: getTierColor(tier)),
                  Text(' $tier 티어'),
                  const SizedBox(width: 12),
                  const Icon(Icons.emoji_events, size: 16),
                  Text(' $rank위'),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  static Color getTierColor(String tier) {
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
        return Colors.black;
    }
  }
}
