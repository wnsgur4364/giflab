import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'globals.dart';

Future<void> uploadCoordiPost({
  required File imageFile,
  required String description,
  required List<String> selectedTags,
  required BuildContext context,
}) async {
  final uri = Uri.parse('http://10.0.2.2:8000/upload');

  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    imageFile.path,
    filename: basename(imageFile.path),
  ));
  request.fields['description'] = description;
  request.fields['tags'] = selectedTags.join(', ');
  request.fields['region'] = globalRegionKr;
  request.fields['temperature'] = globaltemp.toString();

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ 업로드 성공")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ 실패: ${response.statusCode}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("⚠ 에러: $e")),
    );
  }
}
