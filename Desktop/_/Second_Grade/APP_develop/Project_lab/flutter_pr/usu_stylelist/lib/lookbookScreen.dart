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
        final decoded = jsonDecode(response.body);
        final List data = decoded['posts'];
        setState(() {
          posts = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: const Icon(Icons.style, color: Colors.white),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index] as Map<String, dynamic>;
          final filename = post['filename'] as String?;
          final imageUrl = filename != null ? 'http://10.0.2.2:8000/uploads/$filename' : '';
          final images = imageUrl.isNotEmpty ? [imageUrl] : [];

          final title = post['description'] ?? '제목 없음';
          final description = post['tags'] ?? '설명 없음';
          final temp = post['temperature']?.toString();
          final postId = post['id'] as int;

          return LookbookPost(
            images: List<String>.from(images),
            title: title,
            description: description,
            temperature: temp,
            postId: postId,
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
  final int postId;

  const LookbookPost({
    super.key,
    required this.images,
    required this.title,
    required this.description,
    this.temperature,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 300,
            child: images.isEmpty
                ? const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey))
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
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 60)),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(description, style: TextStyle(color: Colors.grey[700])),
          ),
          if (temperature != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('현재 온도: $temperature°C', style: TextStyle(color: Colors.blue[700])),
            ),
          CommentSection(postId: postId),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final int postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  List<Map<String, dynamic>> comments = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> fetchComments() async {
    final res = await http.get(Uri.parse('http://10.0.2.2:8000/comments/${widget.postId}'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        comments = List<Map<String, dynamic>>.from(data['comments']);
      });
    }
  }

  Future<void> submitComment() async {
    final content = controller.text.trim();
    if (content.isEmpty) return;

    final res = await http.post(
      Uri.parse('http://10.0.2.2:8000/comment'),
      body: {
        'post_id': widget.postId.toString(),
        'user_id': '1', // 나중에 로그인 기능 연동 시 교체
        'content': content,
      },
    );

    if (res.statusCode == 200) {
      controller.clear();
      FocusScope.of(context).unfocus();
      fetchComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...comments.map((c) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(c['content']),
              subtitle: Text(
                DateTime.parse(c['created_at']).toLocal().toString().split('.')[0],
              ),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: '댓글을 입력하세요'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: submitComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
