// TodayCoordiPage.dart
import 'package:first_app/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'styleDetail.dart';

class TodayCoordiPage extends StatefulWidget {
  const TodayCoordiPage({super.key});

  @override
  State<TodayCoordiPage> createState() => _TodayCoordiPageState();
}

class _TodayCoordiPageState extends State<TodayCoordiPage> {
  late Future<List<dynamic>> _fetchCoordiItems;
  String selectedRegion = globalRegionKr == '전체' ? "대한민국" : globalRegionKr;
  final List<String> regions = [
    '전체',
    '서울',
    '대전',
    '부산',
    '광주',
    '대구',
    '인천',
    '울산',
    '세종',
  ];
  String get displayRegion => selectedRegion == '전체' ? '대한민국' : selectedRegion;
  @override
  void initState() {
    super.initState();
    _fetchCoordiItems = fetchCoordiItems();
  }

  Future<List<dynamic>> fetchCoordiItems() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/posts'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final posts = decoded['posts'];
        if (posts is List) {
          if (selectedRegion == '전체') {
            return posts.take(8).toList();
          } else {
            return posts
                .where((post) => post['region'] == selectedRegion)
                .take(8)
                .toList();
          }
        } else {
          throw Exception('"posts" 필드가 리스트가 아닙니다.');
        }
      } else {
        throw Exception('서버 응답 실패');
      }
    } catch (e) {
      print("Error fetching items: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 8,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 30),
            const SizedBox(width: 8),
            Text(
              "$displayRegion의 패션왕",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.amberAccent,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.star, color: Colors.amberAccent, size: 28),
          ],
        ),
        leading: const Icon(Icons.shield, color: Colors.amberAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.amberAccent),
            onPressed: () {},
            tooltip: '검색',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedRegion,
              items:
                  regions.map((String region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRegion = newValue!;
                  _fetchCoordiItems = fetchCoordiItems();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchCoordiItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('코디 아이템이 없습니다.'));
                } else {
                  final coordiItems = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: coordiItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, index) {
                      try {
                        final item = coordiItems[index];
                        print('top: ${item['top']}, bottom: ${item['bottom']}, outer: ${item['outer']}');

                        final imageUrl =
                            'http://10.0.2.2:8000/uploads/${item['filename']}';
                        final title =
                            item['description']?.toString() ?? '제목 없음';
                        final tagString = item['tags']?.toString() ?? '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CoordDetailPage(
                                      imageUrl: imageUrl,
                                      title: title,
                                      tags:
                                          tagString
                                              .split(',')
                                              .map((e) => e.trim())
                                              .toList(),
                                      description: item['description'] ?? '',
                                      temperatureMax:
                                          item['temperature_max']?.toString() ??
                                          '',
                                      temperatureMin:
                                          item['temperature_min']?.toString() ??
                                          '',
                                      weather:
                                          item['weather_desc']?.toString() ??
                                          '',
                                      username: item['username'] ?? '익명',
                                      tier: item['tier'] ?? 'Bronze',
                                      rank: item['rank'] ?? 9999,
                                      emojiUrl:
                                          item['emoji'] != null &&
                                                  item['emoji']
                                                      .toString()
                                                      .isNotEmpty
                                              ? 'http://10.0.2.2:8000/uploads/${item['emoji']}'
                                              : '',
                                      top: item['top']?.toString() ?? '',
                                      bottom: item['bottom']?.toString() ?? '',
                                      outer: item['outer']?.toString() ?? '',
                                      shoes: item['shoes']?.toString() ?? '',
                                      etc: item['etc']?.toString() ?? '',
                                      
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child:
                                      imageUrl.isNotEmpty
                                          ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) => const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                ),
                                          )
                                          : Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                          ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        tagString,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (_) {
                        return const Card(child: Center(child: Text('렌더링 오류')));
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
