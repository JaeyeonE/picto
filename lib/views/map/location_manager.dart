// lib/views/map/location_manager.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class LocationManager {
  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? currentLocation;
  final Function(LatLng) onLocationChanged;
  final Function(String) onError;

  LocationManager({
    required this.onLocationChanged,
    required this.onError,
  });

  Future<bool> handleLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 거부되었습니다')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.')),
      );
      return false;
    }
    return true;
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    final hasPermission = await handleLocationPermission(context);
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      );

      currentLocation = LatLng(position.latitude, position.longitude);
      onLocationChanged(currentLocation!);
    } catch (e) {
      onError('현재 위치를 가져오는데 실패했습니다: $e');
    }
  }

  Future<void> startLocationUpdates(BuildContext context) async {
    final hasPermission = await handleLocationPermission(context);
    if (!hasPermission) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 30,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        currentLocation = LatLng(position.latitude, position.longitude);
        onLocationChanged(currentLocation!);
      },
      onError: (e) => onError('위치 스트림 에러: $e'),
    );
  }

  Future<LatLng?> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      onError('위치를 찾을 수 없습니다');
    }
    return null;
  }

  void dispose() {
    _positionStreamSubscription?.cancel();
  }
}