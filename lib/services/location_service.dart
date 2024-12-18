import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position> getCurrentLocation() async {
    if (!await isLocationEnabled()) {
      throw Exception('위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 활성화해주세요.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );

      print('위치 정보 획득 성공: lat=${position.latitude}, lng=${position.longitude}');
      return position;
    } catch (e) {
      print('위치 정보 획득 실패: $e');
      throw Exception('위치 정보를 가져오는데 실패했습니다: $e');
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print('위치 권한 요청 거부됨');
          return false;
        }
      }

      print('위치 권한 상태: $permission');
      return permission != LocationPermission.deniedForever;
    } catch (e) {
      print('위치 권한 요청 중 오류 발생: $e');
      return false;
    }
  }

  static Future<String> getAddressFromCoordinates(
      double? lat, double? lng) async {
    if (lat == null || lng == null) {
      return '위치 정보 없음';
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return '위치 정보 없음';
      }

      Placemark place = placemarks[0];

      // 한국 주소 형식에 맞게 구성
      List<String> addressParts = [];

      // 시/도
      if (place.administrativeArea?.isNotEmpty == true) {
        addressParts.add(place.administrativeArea!);
      }

      // 시/군/구
      if (place.locality?.isNotEmpty == true) {
        addressParts.add(place.locality!);
      } else if (place.subLocality?.isNotEmpty == true) {
        addressParts.add(place.subLocality!);
      }
      return addressParts.isNotEmpty ? addressParts.join(' ') : '위치 정보 없음';
    } catch (e) {
      print('주소 변환 실패: $e');
      return '위치 정보 없음';
    }
  }
}
