import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'globals.dart';

class LocationService {
  static final _koreanToEnglishMap = {
    '서울특별시': 'Seoul',
    '부산광역시': 'Busan',
    '대구광역시': 'Daegu',
    '인천광역시': 'Incheon',
    '광주광역시': 'Gwangju',
    '대전광역시': 'Daejeon',
    '울산광역시': 'Ulsan',
    '수원시': 'Suwon',
    '성남시': 'Seongnam',
    '고양시': 'Goyang',
    '용인시': 'Yongin',
    '청주시': 'Cheongju',
    '천안시': 'Cheonan',
  };

  static Future<void> initRegion() async {
    try {
      // 위치 권한 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();

      // 위도 경도 → Placemark (지역명)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // 한글 지역명
        final kr = placemark.locality ?? placemark.administrativeArea ?? '알 수 없음';
        globalRegionKr = kr;

        // 영어 지역명 매핑
        globalRegion = _koreanToEnglishMap[kr] ?? 'Seoul';
      }
    } catch (e) {
      print("❌ 지역 정보 가져오기 실패: $e");
      globalRegion = 'Seoul';
      globalRegionKr = '서울';
    }
  }
}
