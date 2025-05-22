
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'todayCoordiPage.dart';
// splash screen
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USU Style App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(image: AssetImage('assets/gifreb/logo.png'), width: 120),
      ),
    );
  }
}

// 바텀 내비게이션
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MyHomePage(title: '오늘의 코디 추천'),
    const TodayCoordiPage(),
    const Center(child: Text('게시판')),
    const Center(child: Text('설정')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.shirt), label: '코디'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.circlePlus), label: '업로드'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.images), label: '룩북'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}

// 홈 페이지
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class TourData {
  final String? title;
  final String? imagePath;

  TourData({this.title, this.imagePath});
  factory TourData.fromJason(Map<String, dynamic> json) {
    return TourData(
      title: json['title'],
      imagePath: json['firstimage'],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String weather = "불러오는 중...";
  String recommendation = "잠시만 기다려 주세요.";

  @override
  void initState() {
    super.initState();
    fetchDaejeonWeather(); // 앱 시작 시 자동 호출
  }

  Future<void> fetchDaejeonWeather() async {
  const apiKey = 'bb8e0ba2bfb53906a2bf3802059d4de5';
  final url =
      'https://api.openweathermap.org/data/2.5/weather?q=Daejeon,KR&appid=$apiKey&units=metric&lang=kr';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final temp = data['main']['temp'].round();
      final feelsLike = data['main']['feels_like'].round();
      final desc = data['weather'][0]['description'];

      setState(() {
        weather = "$temp도, $desc";
        recommendation = temp > 25
            ? "얇은 반팔 + 린넨 팬츠 추천!"
            : temp > 15
                ? "가디건이나 셔츠 추천!"
                : "보온이 되는 코트 추천!";
      });
    } else {
      setState(() {
        weather = "불러오기 실패";
        recommendation = "잠시 후 다시 시도해주세요.";
      });
    }
  } catch (e) {
    setState(() {
      weather = "네트워크 오류";
      recommendation = "인터넷 연결 확인 필요";
    });
  }
}


  @override
 Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        // 상단: 로고 + 검색창
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/gifreb/logo.png', width: 100),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "검색어를 입력하세요",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              Icon(Icons.shopping_bag_outlined),
            ],
          ),
        ),

        // 🌤 날씨 카드
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: fetchDaejeonWeather,
            child: ListTile(
              leading: Icon(Icons.wb_sunny, size: 40, color: Colors.orange),
              title: Text(weather),
              subtitle: Text(recommendation),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🧑‍💼 내 정보 카드
        Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/profile.jpg'), // 본인 이미지
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("우수123", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("💎 Platinum 티어", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("🏆 전체 사용자 중 42위"),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 📊 활동 요약
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("코디", "14"),
              _buildStat("좋아요", "210"),
              _buildStat("댓글", "55"),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
Widget _buildStat(String label, String count) {
  return Column(
    children: [
      Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 14)),
    ],
  );
}

}

