import 'package:flutter/material.dart';

class LookbookPost extends StatelessWidget {
  final List<String> images;
  final String title;
  final String description;
  final int postId;

  const LookbookPost({
    super.key,
    required this.images,
    required this.title,
    required this.description,
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
            child: images.isNotEmpty
                ? PageView.builder(
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
                  )
                : const Center(
                    child: Icon(Icons.image_not_supported, size: 60),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              description,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),

          // 댓글 섹션 추가
          CommentSection(postId: postId),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
