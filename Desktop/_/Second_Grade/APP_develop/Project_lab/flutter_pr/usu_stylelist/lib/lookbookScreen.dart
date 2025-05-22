import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';

class LookbookPage extends StatefulWidget {
  const LookbookPage({super.key});

  @override
  State<LookbookPage> createState() => _LookbookPageState();
}

class _LookbookPageState extends State<LookbookPage> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLookbookPosts();
  }

  Future<void> fetchLookbookPosts() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/posts'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          posts = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      print('Error fetching posts: $e');
      print(stacktrace);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  if (isLoading) return const Center(child: CircularProgressIndicator());
  if (posts.isEmpty) return const Center(child: Text('게시물이 없습니다.'));

  return Scaffold(
    appBar: AppBar(
  backgroundColor: Colors.black,
  elevation: 4,
  centerTitle: true,
  title: Text(
    "$globalRegionKr의 패션",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.white,
      shadows: [
        Shadow(
          color: Colors.black38,
          offset: Offset(1, 1),
          blurRadius: 3,
        ),
      ],
    ),
  ),
  leading: Icon(Icons.style, color: Colors.white),
  actions: [
    IconButton(
      icon: Icon(Icons.search, color: Colors.white),
      onPressed: () {
        // 검색 버튼 클릭 시 동작 추가 가능
      },
    ),
    SizedBox(width: 8),
  ],
),
    body: ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index] as Map<String, dynamic>;

        // 이미지 처리 - List<String> 또는 단일 String 처리
        List<String> images = [];
        if (post['image_url'] != null) {
          if (post['image_url'] is List) {
            images = List<String>.from(post['image_url']);
          } else if (post['image_url'] is String) {
            images = [post['image_url']];
          }
        }

        final title = post['title'] as String? ?? '제목 없음';
        final description = post['description'] as String? ?? '설명 없음';
        final temp = post['temperature'] != null ? post['temperature'].toString() : null;

        return LookbookPost(
          images: images,
          title: title,
          description: description,
          temperature: temp,
        );
      },
    ),
  );
}
}

class LookbookPost extends StatelessWidget {
  final List<String> images;
  final String title;
  final String description;
  final String? temperature;

  const LookbookPost({
    super.key,
    required this.images,
    required this.title,
    required this.description,
    this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // 배경 흰색 고정
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 이미지 영역
          SizedBox(
            height: 350,
            child: images.isEmpty
                ? const Center(
                    child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  )
                : PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image, size: 60)),
                      );
                    },
                  ),
          ),

          // 좋아요, 댓글, 공유 아이콘 (간단히 구현)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.favorite_border, size: 28),
                SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 28),
                SizedBox(width: 16),
                Icon(Icons.send, size: 28),
                Spacer(),
                Icon(Icons.bookmark_border, size: 28),
              ],
            ),
          ),

          // 좋아요 수 및 본문
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '좋아요 ${images.length * 3}개', // 임시 좋아요 수
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),

          // 온도 표시 (있으면)
          if (temperature != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                '현재 온도: $temperature °C',
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
              ),
            ),

          // 댓글 달기 부분 (간단히)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              '댓글 달기...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),

          // 구분선
          Divider(color: Colors.grey[300], thickness: 8),
        ],
      ),
    );
  }
}
