// uploadfile.dart
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
  required String regionDetail,
  required String top,
  required String bottom,
  required String outer,
  required String shoes,
  required String etc,
  required String weather_desc,
  required double temperature_max,
  required double temperature_min,
}) async {
  final uri = Uri.parse('http://10.0.2.2:8000/upload');
  final request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: basename(imageFile.path),
    ))
   ..fields['description'] = description
    ..fields['tags'] = selectedTags.join(', ')
    ..fields['region'] = globalRegionKr
    ..fields['user_id'] = globalUserId.toString()
    ..fields['region_detail'] = regionDetail
    ..fields['top'] = top
    ..fields['bottom'] = bottom
    ..fields['outer'] = outer
    ..fields['shoes'] = shoes
    ..fields['etc'] = etc
    ..fields['temperature_max'] = temperature_max.toString()
    ..fields['temperature_min'] = temperature_min.toString()
    ..fields['weather_desc'] = weather_desc;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final response = await request.send();
    Navigator.pop(context); // 로딩 닫기

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ 업로드 성공")),
      );
      Navigator.pop(context); // 이전 화면으로 돌아가기
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
