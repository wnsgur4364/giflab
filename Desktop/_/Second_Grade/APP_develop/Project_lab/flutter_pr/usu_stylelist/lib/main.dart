import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todayCoordiPage.dart';
import 'uploadStyle.dart';
import 'locationService.dart';
import '../globals.dart';
import 'lookbookScreen.dart';
import 'setting_page.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/api_data.env');
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
    _initSplash();
  }

  Future<void> _initSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    await checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final username = prefs.getString("username");

    if (userId != null && username != null) {
      globalUserId = userId;
      globalUsername = username;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
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
    const Center(child: Text('업로드')),
    const LookbookPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UploadStylePage()),
      );
      return;
    }

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String weather = "불러오는 중...";
  String recommendation = "잠시만 기다려 주세요.";

  @override
  void initState() {
    super.initState();
    fetchDaejeonWeather();
  }

  Future<void> fetchDaejeonWeather() async {
    String apiKey = dotenv.get('apiKey');
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$globalRegion,KR&appid=$apiKey&units=metric&lang=kr';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['list'] as List;

        String today = DateTime.now().toIso8601String().substring(0, 10);

        double minTemp = double.infinity;
        double maxTemp = -double.infinity;

        for (var entry in list) {
          final dtTxt = entry['dt_txt'];
          if (dtTxt.startsWith(today)) {
            double temp = (entry['main']['temp'] as num).toDouble();
            if (temp < minTemp) minTemp = temp;
            if (temp > maxTemp) maxTemp = temp;
            if (dtTxt.contains('12:00:00')) {
              desc = entry['weather'][0]['description'];
            }
          }
        }

        globalTempMin = minTemp.round();
        globalTempMax = maxTemp.round();
        globaltemp = maxTemp.round();

        setState(() {
          weather = "최저: $globalTempMin°C / 최고: $globalTempMax°C, $desc";
          recommendation = globaltemp > 25
              ? "얇은 반팔 + 린넨 팬츠 추천!"
              : globaltemp > 15
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
        recommendation = "$e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
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
          

          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: fetchDaejeonWeather,
              child: ListTile(
                leading: Icon(Icons.wb_sunny, size: 40, color: Colors.orange),
                title: Text(weather),
                subtitle: Text(recommendation),
              ),
            ),
          ),
           Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('assets/gifreb/logo_no.png'),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shield,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          globalUsername,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(
                              Icons.diamond,
                              size: 18,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 6),
                            Text("Platinum 티어", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(
                              Icons.emoji_events,
                              size: 18,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 6),
                            Text("전체 사용자 중 42위"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat("코디", "14", icon: Icons.style),
                            _buildStat("좋아요", "210", icon: Icons.favorite),
                            _buildStat("댓글", "55", icon: Icons.comment),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: 
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flag, color: Colors.blueAccent, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "일일 미션",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "🧡좋아요 누르기.",
                            style: TextStyle(fontSize: 14),
                          ),
                          
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              LinearProgressIndicator(
                                value: 0.0,
                                backgroundColor: Colors.blue[100],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent,
                                ),
                              ),
                              const Positioned.fill(
                                child: Center(
                                  child: Text(
                                    "30%",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "오늘의 날씨에 맞춰 코디 올리기.",
                            style: TextStyle(fontSize: 14),
                          ),
                          
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              LinearProgressIndicator(
                                value: 0.5,
                                backgroundColor: Colors.blue[100],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent,
                                ),
                              ),
                              const Positioned.fill(
                                child: Center(
                                  child: Text(
                                    "50%",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          const Text(
                            "주간 미션",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          
                          const Text(
                            "🧡 좋아요 10개 받기.",
                            style: TextStyle(fontSize: 14),
                          ),
                          
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              LinearProgressIndicator(
                                value: 0.5,
                                backgroundColor: Colors.blue[100],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent,
                                ),
                              ),
                              const Positioned.fill(
                                child: Center(
                                  child: Text(
                                    "50%",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const UploadStylePage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("미션 참여하기"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String count, {IconData? icon}) {
    return Column(
      children: [
        if (icon != null) Icon(icon, color: Colors.blueAccent, size: 28),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blueGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
