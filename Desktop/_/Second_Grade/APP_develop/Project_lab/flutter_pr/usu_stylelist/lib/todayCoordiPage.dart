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

  @override
  void initState() {
    super.initState();
    _fetchCoordiItems = fetchCoordiItems();
  }

  Future<List<dynamic>> fetchCoordiItems() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/posts'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.take(8).toList();
    } else {
      throw Exception('Failed to load coordi items');
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
            Icon(Icons.emoji_events, color: Colors.amberAccent, size: 30),
            SizedBox(width: 8),
            Text(
              "$globalRegionKr의 패션왕",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.amberAccent,
                shadows: [
                  Shadow(
                    color: Colors.orangeAccent.withOpacity(0.6),
                    offset: Offset(2, 2),
                    blurRadius: 6,
                  ),
                  Shadow(
                    color: Colors.black87,
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.star, color: Colors.amberAccent, size: 28),
          ],
        ),
        leading: Icon(Icons.shield, color: Colors.amberAccent),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.amberAccent),
            onPressed: () {},
            tooltip: '검색',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchCoordiItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('코디 아이템이 없습니다.'));
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
                      final item = coordiItems[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => CoordDetailPage(
                                    imageUrl: item['image_url'],
                                    title: item['title'],
                                    tags:
                                        item['tags'] is String
                                            ? [item['tags']]
                                            : item['tags'],
                                    description: item['description'] ?? '',
                                    temperature:
                                        item['temperature']?.toString() ?? '',
                                    weather: item['weather']?.toString() ?? '',
                                    username: item['username'] ?? '익명',
                                    tier: item['tier'] ?? 'Bronze',
                                    rank: item['rank'] ?? 9999,
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
                                child: Image.network(
                                  item['image_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) =>
                                          Icon(Icons.image_not_supported),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      (item['tags'] is List)
                                          ? (item['tags'] as List).join(', ')
                                          : item['tags'].toString(),
                                      style: TextStyle(color: Colors.grey[600]),
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
