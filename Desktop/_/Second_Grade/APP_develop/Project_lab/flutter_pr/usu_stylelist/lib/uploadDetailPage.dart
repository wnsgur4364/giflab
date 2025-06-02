import 'dart:io';
import 'package:flutter/material.dart';
import 'uploadfile.dart';
import 'globals.dart';

class UploadDetailPage extends StatefulWidget {
  final File imageFile;
  const UploadDetailPage({super.key, required this.imageFile});

  @override
  State<UploadDetailPage> createState() => _UploadDetailPageState();
}

class _UploadDetailPageState extends State<UploadDetailPage> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _topController = TextEditingController();
  final TextEditingController _bottomController = TextEditingController();
  final TextEditingController _outerController = TextEditingController();
  final TextEditingController _shoesController = TextEditingController();
  final TextEditingController _etcController = TextEditingController();

  final List<String> _tags = ["스트릿", "미니멀", "캠퍼스룩"];
  final Set<String> _selectedTags = {};

  void _toggleTag(String tag) {
    setState(() {
      _selectedTags.contains(tag) ? _selectedTags.remove(tag) : _selectedTags.add(tag);
    });
  }

  void _handleUpload() {
    uploadCoordiPost(
      imageFile: widget.imageFile,
      description: _descController.text,
      selectedTags: _selectedTags.toList(),
      context: context,
      regionDetail: "", // 제거됨
      top: _topController.text,
      bottom: _bottomController.text,
      outer: _outerController.text,
      shoes: _shoesController.text,
      etc: _etcController.text,
      weather_desc: desc,
      temperature_max: globalTempMax.toDouble(),
      temperature_min: globalTempMin.toDouble(),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("코디 업로드")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.file(widget.imageFile, height: 220, fit: BoxFit.cover),
            const SizedBox(height: 16),
            _buildInput("코디 설명", _descController),
            _buildInput("상의 정보", _topController),
            _buildInput("하의 정보", _bottomController),
            _buildInput("아우터 정보", _outerController),
            _buildInput("신발 정보", _shoesController),
            _buildInput("기타 정보", _etcController),
            const SizedBox(height: 16),
            const Text("스타일 태그 선택", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                return ChoiceChip(
                  label: Text(tag),
                  selected: _selectedTags.contains(tag),
                  onSelected: (_) => _toggleTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleUpload,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("공유하기"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
