import 'package:flutter/material.dart';

class CoordDetailPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<dynamic> tags;
  final String temperature;
  final String description;

  const CoordDetailPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.description,
    required this.temperature
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

          // 타이틀 및 태그
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
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

                // 설명 임시 텍스트
                const Text(
                  '이 스타일은 봄/가을에 잘 어울리는 캐주얼한 룩입니다. '
                  '심플한 색조합과 패턴이 포인트이며, 외출이나 데일리룩으로도 추천됩니다.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
