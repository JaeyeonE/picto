import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      if (!await isLocationEnabled()) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('위치 정보를 가져오는데 실패했습니다: $e');
      return null;
    }
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      return permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    }

    return permission != LocationPermission.deniedForever;
  }
}


// 다른 파일에서 사용할 때 이렇게 사용하면 될거같아요

// final locationService = LocationService();

// // 위치 서비스 활성화 여부 확인
// bool isEnabled = await locationService.isLocationEnabled();

// // 현재 위치 가져오기
// Position? position = await locationService.getCurrentLocation();
// if (position != null) {
//   print('위도: ${position.latitude}, 경도: ${position.longitude}');
// }