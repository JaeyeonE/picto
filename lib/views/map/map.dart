// lib/views/map/map.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/photo_manager_service.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/views/map/zoom_position.dart';
import 'package:picto/widgets/common/actual_tag_list.dart';
import '../map/search_screen.dart';
import '../../widgets/common/map_header.dart';
import '../../widgets/common/navigation.dart';
import 'marker_manager.dart';

// StatefulWidget으로 MapScreen 클래스 정의
class MapScreen extends StatefulWidget {
  final User initialUser;

  const MapScreen({
    super.key,
    required this.initialUser,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 상태 변수들 정의
  int selectedIndex = 2; // 네비게이션 바에서 선택된 인덱스
  List<String> selectedTags = ['전체']; // 선택된 태그 목록
  GoogleMapController? mapController; // 구글맵 컨트롤러
  LatLng? currentLocation; // 현재 위치
  StreamSubscription<Position>? _positionStreamSubscription; // 위치 업데이트 구독
  Set<Marker> markers = {}; // 모든 마커 세트
  String _currentLocationType = 'large'; // 현재 위치 타입(large/middle/small)
  final _userService =
      UserManagerService(host: 'http://3.35.153.213:8086'); // 사용자 관리 서비스
  final _photoService =
      PhotoManagerService(host: 'http://3.35.153.213:8082'); // 사진 관리 서비스
  bool _isLoading = false; // 로딩 상태
  final _searchController = TextEditingController(); // 검색 컨트롤러
  User? currentUser; // 현재 사용자 정보
  MarkerManager? _markerManager; // 마커 관리자

  @override
  void initState() {
    super.initState();
    currentUser = widget.initialUser; // 현재 사용자 설정
    _initializeUser(); // 기존 초기화 함수 유지
    _initializeLocationServices();
  }

  @override
  void dispose() {
    mapController?.dispose(); // 맵 컨트롤러 해제
    _positionStreamSubscription?.cancel(); // 위치 구독 취소
    _searchController.dispose(); // 검색 컨트롤러 해제
    super.dispose();
  }

  // 사용자 초기화 함수
  Future<void> _initializeUser() async {
    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        final user = await _userService.getUserProfile(userId);
        setState(() {
          currentUser = user;
          _markerManager = MarkerManager(currentUserId: int.parse(user.userId));
        });
      }
    } catch (e) {
      debugPrint('사용자 정보 로드 실패: $e');
    }
  }

  // 카메라 이동 시 실행되는 함수 - 줌 레벨에 따라 위치 타입 변경
  void _onCameraMove(CameraPosition position) {
    if (currentUser == null || _markerManager == null)
      return; // 사용자 정보가 없으면 처리하지 않음

    String newLocationType;
    if (position.zoom >= 15) {
      newLocationType = 'small'; // 읍/면/동 수준
    } else if (position.zoom >= 12) {
      newLocationType = 'middle'; // 시/군/구 수준
    } else {
      newLocationType = 'large'; // 도/광역시 수준
    }

    if (_currentLocationType != newLocationType) {
      setState(() {
        _currentLocationType = newLocationType;
      });

      // 줌 레벨에 따라 적절한 함수 호출
      if (newLocationType == 'small') {
        _loadNearbyPhotos();
      } else {
        _loadRepresentativePhotos();
      }
    }

    // 현재 줌 레벨에 맞는 마커만 표시
    setState(() {
      markers = _markerManager!.getMarkersForZoomLevel(position.zoom);
    });
  }

  // 대표 사진들을 로드하는 함수
  Future<void> _loadRepresentativePhotos() async {
    if (_isLoading || currentUser == null || _markerManager == null) return;
    setState(() => _isLoading = true);

    try {
      final photos = await _photoService.getRepresentativePhotos(
        locationType: _currentLocationType,
        count: 10,
      );

      // 태그 필터링된 사진만 선택
      final filteredPhotos = photos
          .where((photo) =>
              selectedTags.contains('전체') ||
              (photo.tag != null && selectedTags.contains(photo.tag!)))
          .toList();

      // MarkerManager를 통해 마커 생성
      final newMarkers = await _markerManager!
          .createMarkersFromPhotos(filteredPhotos, _currentLocationType);

      if (mounted) {
        setState(() {
          markers = newMarkers;
          print("Updated markers set, size: ${markers.length} line 139");
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진을 불러오는데 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 위치 권한을 확인하고 요청하는 함수
  Future<bool> _handleLocationPermission() async {
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

  // 주변 사진 로드 함수
  Future<void> _loadNearbyPhotos() async {
    if (_isLoading || currentUser == null || _markerManager == null) return;
    setState(() => _isLoading = true);

    try {
      final userId = await _userService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      final photos = await _photoService.getNearbyPhotos(userId);
      Text("Received photos: $photos");

      // 태그 필터링된 사진만 선택
      final filteredPhotos = photos
          .where((photo) =>
              selectedTags.contains('전체') ||
              (photo.tag != null && selectedTags.contains(photo.tag!)))
          .toList();

      // MarkerManager를 통해 마커 생성
      final newMarkers = await _markerManager!
          .createMarkersFromPhotos(filteredPhotos, 'small');

      if (mounted) {
        setState(() {
          markers = newMarkers;
          print("Updated markers set, size: ${markers.length} line 206");
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('주변 사진을 불러오는데 실패했습니다: ${e.toString()}'),
            action: SnackBarAction(
              label: '다시 시도',
              onPressed: _loadNearbyPhotos,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 현재 위치 마커를 업데이트하는 함수
  void _updateMyLocationMarker(LatLng location) {
    setState(() {
      markers.removeWhere(
          (marker) => marker.markerId == const MarkerId("myLocation"));
      markers.add(
        Marker(
          markerId: const MarkerId("myLocation"),
          position: location,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "현재 위치"),
        ),
      );
    });
  }

  // 현재 위치를 가져오고 지도를 이동시키는 함수
  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50, // 50미터마다 위치 업데이트
        ),
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (mapController != null && currentLocation != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation!,
              zoom: 15,
            ),
          ),
        );
        _updateMyLocationMarker(currentLocation!);
        _loadNearbyPhotos();
      }
    } catch (e) {
      debugPrint('현재 위치를 가져오는데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 위치를 가져오는데 실패했습니다')),
      );
    }
  }

  // 실시간 위치 업데이트를 시작하는 함수
  Future<void> _startLocationUpdates() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 30, // 30미터마다 위치 업데이트
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
        _updateMyLocationMarker(currentLocation!);
      },
      onError: (e) {
        debugPrint('위치 스트림 에러: $e');
      },
    );
  }

  // 지도를 새로고침하는 함수
  Future<void> _refreshMap() async {
    if (_currentLocationType == 'small') {
      await _loadNearbyPhotos();
    } else {
      await _loadRepresentativePhotos();
    }
  }

  // 위치 서비스를 초기화하는 함수
  Future<void> _initializeLocationServices() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    await _getCurrentLocation();
    _startLocationUpdates();
    if (mounted) {
      setState(() {});
    }
  }

  // 태그 선택 시 실행되는 함수
  void onTagsSelected(List<String> tags) {
    setState(() {
      selectedTags = tags;
    });
    _loadNearbyPhotos();
  }

  // 위치 검색 함수
  Future<void> _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location =
            LatLng(locations.first.latitude, locations.first.longitude);
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: location,
              zoom: 15,
            ),
          ),
        );
        await _loadNearbyPhotos();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치를 찾을 수 없습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // 로그 많이 안 찍히도록..
      child: Scaffold(
        body: Stack(
          children: [
            RepaintBoundary(
              // GoogleMap에 대한 전용 RepaintBoundary
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  if (currentLocation != null && currentUser != null) {
                    _loadRepresentativePhotos();
                  }
                },
                onCameraMove: _onCameraMove,
                onCameraIdle: _loadRepresentativePhotos,
                initialCameraPosition: CameraPosition(
                  target: currentLocation ?? const LatLng(37.5665, 126.9780),
                  zoom: 11.0,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),

            // 상단 Column에 RepaintBoundary 추가
            RepaintBoundary(
              child: Column(
                children: [
                  // 맵 헤더는 자주 변경되지 않으므로 RepaintBoundary로 감싸기
                  RepaintBoundary(
                    child: MapHeader(
                      onSearchPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SearchScreen(
                              onSearch: (location, tags) async {
                                if (mapController != null) {
                                  await mapController!.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(location.latitude,
                                            location.longitude),
                                        zoom: 15,
                                      ),
                                    ),
                                  );
                                  await _loadNearbyPhotos();
                                }
                              },
                              defaultLocation: currentLocation ??
                                  const LatLng(37.5665, 126.9780),
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOutCubic;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 300),
                          ),
                        );
                      },
                    ),
                  ),

                  // TagSelector도 RepaintBoundary로 감싸기
                  RepaintBoundary(
                    child: TagSelector(
                      selectedTags: selectedTags,
                      onTagsSelected: onTagsSelected,
                    ),
                  ),
                ],
              ),
            ),

            // 로딩 인디케이터
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // 오른쪽 하단 새로고침 버튼
            Positioned(
              right: 16,
              bottom: 50,
              child: RepaintBoundary(
                // 새로고침 버튼도 RepaintBoundary로 감싸기
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'refresh',
                      onPressed: _refreshMap,
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              // zoom 정도 표시
              top: 100,
              left: 0,
              right: 0,
              child: LocationLevelIndicator(locationType: _currentLocationType),
            ),
          ],
        ),

        // 하단 네비게이션 바에도 RepaintBoundary 적용
        bottomNavigationBar: RepaintBoundary(
          child: CustomNavigationBar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
              if (index == 2 && selectedIndex == 2) {
                _getCurrentLocation();
              }
            },
            currentUser: widget.initialUser,
          ),
        ),
      ),
    );
  }
}
