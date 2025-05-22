import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart'as path;
import 'dart:convert';
import 'globals.dart';


class UploadDetailPage extends StatefulWidget {
  final File imageFile;

  const UploadDetailPage({super.key, required this.imageFile});

  @override
  State<UploadDetailPage> createState() => _UploadDetailPageState();
}

class _UploadDetailPageState extends State<UploadDetailPage> {
  final TextEditingController _descController = TextEditingController();
  final List<String> _tags = ["스트릿", "미니멀", "캠퍼스룩"];
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> uploadCoordiPost() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final uri = Uri.parse('http://10.0.2.2:8000/upload');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      widget.imageFile.path,
      filename: path.basename(widget.imageFile.path),
    ));

    request.fields['description'] = _descController.text;
    request.fields['tags'] = _selectedTags.join(', ');
    request.fields['region'] = globalRegionKr;
    request.fields['temperature'] = globaltemp.toString();

    try {
      final response = await request.send();

      Navigator.pop(context); // 로딩 제거

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ 업로드 성공")),
        );
        Navigator.pop(context); // 이전 화면으로 이동
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ 에러: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("코디 업로드"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                widget.imageFile,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    hintText: "오늘의 코디를 소개해 주세요 😊",
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("태그를 선택하세요", style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _tags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => _toggleTag(tag),
                  selectedColor: Colors.blueAccent,
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: uploadCoordiPost,
              child: const Text("공유하기"),
            ),
          ],
        ),
      ),
    );
  }
}
