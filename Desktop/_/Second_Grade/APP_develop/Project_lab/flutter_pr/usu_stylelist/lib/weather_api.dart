import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> fetchDaejeonWeather() async {
  const apiKey = 'bb8e0ba2bfb53906a2bf3802059d4de5'; // ← 여기에 너의 키 입력!
  const city = 'Daejeon';
  final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city,KR&appid=$apiKey&units=metric&lang=kr';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final temp = data['main']['temp'];
    final description = data['weather'][0]['description'];
    final feelsLike = data['main']['feels_like'];

    print("📍 대전 날씨: $description");
    print("🌡 기온: $temp°C / 체감: $feelsLike°C");
  } else {
    print("❌ 대전 날씨 요청 실패: ${response.statusCode}");
  }
}
