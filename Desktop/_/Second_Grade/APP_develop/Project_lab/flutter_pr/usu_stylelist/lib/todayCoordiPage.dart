import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TodayCoordiPage extends StatelessWidget {
  const TodayCoordiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final coordiItems = [
      {
        "image": "assets/coordi1.jpg",
        "title": "깔끔하고 쉬운 남친 코디🍀",
        "tags": "#데일리룩 #캠퍼스룩 #데이트룩"
      },
      {
        "image": "assets/coordi2.jpg",
        "title": "부담없이 깔끔하게 입는 여름코디",
        "tags": "#데일리룩 #캐주얼 #미니멀"
      },
      {
        "image": "assets/coordi3.jpg",
        "title": "🖤일본 여행 반팔 가디건🖤",
        "tags": "#데일리룩 #여행룩 #캐주얼"
      },
      {
        "image": "assets/coordi4.jpg",
        "title": "4계절 활용 가능한 트레이닝!",
        "tags": "#데일리룩 #캠퍼스룩 #캐주얼"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("오늘의 코디")),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildFilterBar(),
          const SizedBox(height: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: coordiItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final item = coordiItems[index];
                  return CoordCard(
                    imagePath: item['image']!,
                    title: item['title']!,
                    tags: item['tags']!,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['봄', '여름', '스트릿', '미니멀', '남친룩'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return FilterChip(
            label: Text(filters[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            shape: StadiumBorder(
              side: BorderSide(color: Colors.grey.shade300),
            ),
            backgroundColor: Colors.grey.shade100,
            selectedColor: Colors.blue.shade100,
            selected: false,
            onSelected: (bool selected) {},
          );
        },
      ),
    );
  }
}

class CoordCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String tags;

  const CoordCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.tags,
  });

  @override
  State<CoordCard> createState() => _CoordCardState();
}

class _CoordCardState extends State<CoordCard> with SingleTickerProviderStateMixin {
  bool liked = false;
  int likeCount = 21;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggleLike() {
    setState(() {
      liked = !liked;
      liked ? likeCount++ : likeCount--;
    });
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: _toggleLike,
                    child: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(widget.tags,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text("♥ $likeCount", style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
