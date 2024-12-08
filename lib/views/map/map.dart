// lib/views/map/map.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/photo_manager_service.dart';
import 'package:picto/services/session/location_webSocket_handler.dart';
import 'package:picto/services/session/session_service.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/utils/app_color.dart';
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
  // UI 상태 관련
  int selectedIndex = 2; // 네비게이션 바 선택 인덱스
  List<String> selectedTags = ['전체']; // 선택된 태그 목록
  bool _isLoading = false; // 로딩 상태
  final _searchController = TextEditingController(); // 검색 컨트롤러

  // 구글맵 관련
  GoogleMapController? mapController; // 맵 컨트롤러
  Set<Marker> markers = {}; // 마커 세트
  Set<Circle> circles = {}; // 원 세트
  MarkerManager? _markerManager; // 마커 관리자

  // 위치 관련
  LatLng? currentLocation; // 현재 위치
  StreamSubscription<Position>? _positionStreamSubscription; // 위치 스트림
  LatLng? _lastRefreshLocation; // 마지막 새로고침 위치
  String _currentLocationType = 'large'; // 현재 위치 타입
  String? _previousLocationType; // 이전 위치 타입
  static const double _minimumRefreshDistance = 10.0; // 최소 새로고침 거리(미터)

  // 서비스 인스턴스
  final _userService = UserManagerService(); // 사용자 관리 서비스
  final _photoService = PhotoManagerService(
      // 사진 관리 서비스
      host: 'http://3.35.153.213:8082');
  final SessionService _sessionService = SessionService(); // 세션 서비스
  late final LocationWebSocketHandler _locationHandler;

// 사용자 데이터
  User? currentUser;

// 현재 사용자 정보
  @override
  void initState() {
    super.initState();
    currentUser = widget.initialUser;
    _initializeUser();
    _initializeLocationServices();
    _locationHandler = LocationWebSocketHandler(_sessionService);

    // 세션 메시지 리스너 추가
    _sessionService.getSessionStream().listen((message) async {
      if (message.messagetype == 'LOCATION' &&
          message.lat != null &&
          message.lng != null &&
          message.photoId != null &&
          message.senderId != null &&
          currentLocation != null) {
        final photoLocation = LatLng(message.lat!, message.lng!);
        final distanceInMeters = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          photoLocation.latitude,
          photoLocation.longitude,
        );

        // 3km 반경 내의 사진일 경우만 처리
        if (distanceInMeters <= 3000) {
          try {
            // getNearbyPhotos 호출하여 최신 사진 목록 가져오기
            final photos = await _photoService.getNearbyPhotos();

            // 새로 업로드된 사진 찾기 (photoId로 매칭)
            final newPhoto = photos
                .where((photo) => photo.photoId == message.photoId)
                .firstOrNull;

            if (newPhoto != null && mounted) {
              // MarkerManager로 마커 생성
              final newMarkers = await _markerManager
                  ?.createMarkersFromPhotos([newPhoto], 'small');

              if (newMarkers != null) {
                setState(() {
                  markers.addAll(newMarkers);
                });
              }
            }
          } catch (e) {
            debugPrint('실시간 사진 마커 생성 실패: $e');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    mapController?.dispose(); // 맵 컨트롤러 해제
    _positionStreamSubscription?.cancel(); // 위치 구독 취소
    _searchController.dispose(); // 검색 컨트롤러 해제
    _locationHandler.dispose();
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
          _markerManager = MarkerManager(currentUserId: user.userId);
        });
      }
    } catch (e) {
      debugPrint('사용자 정보 로드 실패: $e');
    }
  }

  // 카메라 이동 시 실행되는 함수 - 줌 레벨에 따라 위치 타입 변경
  void _onCameraMove(CameraPosition position) {
    if (currentUser == null || _markerManager == null) return;

    String newLocationType;
    if (position.zoom >= 15) {
      newLocationType = 'small';
    } else if (position.zoom >= 12) {
      newLocationType = 'middle';
    } else {
      newLocationType = 'large';
    }

    // 위치 타입이 변경되었을 때만 새로고침
    if (_currentLocationType != newLocationType) {
      setState(() {
        _currentLocationType = newLocationType;
        _previousLocationType = _currentLocationType;
      });

      // 위치 타입이 변경됐을 때만 새로고침
      if (_previousLocationType != newLocationType) {
        if (newLocationType == 'small') {
          _loadNearbyPhotos();
        } else {
          _loadRepresentativePhotos();
        }
      }
    }

    // 현재 줌 레벨에 맞는 마커만 표시
    setState(() {
      markers = _markerManager!.getMarkersForZoomLevel(position.zoom);
    });
  }

  // 현재 위치 업데이트 및 필요시 새로고침
  Future<void> _handleLocationUpdate(LatLng newLocation) async {
    setState(() {
      currentLocation = newLocation;
    });
    _updateMyLocationMarker(newLocation);

    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        await _locationHandler.sendLocationWithRetry(
          userId: userId,
          latitude: newLocation.latitude,
          longitude: newLocation.longitude,
        );
        debugPrint('위치 전송 완료');
      }
    } catch (e) {
      debugPrint('Location update failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 업데이트 실패: $e')),
        );
      }
    }

    if (_shouldRefresh(newLocation)) {
      _refreshMap();
      _lastRefreshLocation = newLocation;
    }
  }

  // 새로고침이 필요한지 확인하는 함수
  bool _shouldRefresh(LatLng newLocation) {
    if (_lastRefreshLocation == null) return true;

    final distanceInMeters = Geolocator.distanceBetween(
      _lastRefreshLocation!.latitude,
      _lastRefreshLocation!.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );

    return distanceInMeters >= _minimumRefreshDistance;
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

      final photos = await _photoService.getNearbyPhotos();
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
    // ARGB 색상을 HSV로 변환
    final markerColor = const Color.fromARGB(255, 112, 56, 255);
    final hsvColor = HSVColor.fromColor(markerColor);

    setState(() {
      // 기존 현재 위치 마커 업데이트
      markers.removeWhere(
          (marker) => marker.markerId == const MarkerId("myLocation"));
      markers.add(
        Marker(
          markerId: const MarkerId("myLocation"),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(hsvColor.hue),
          infoWindow: const InfoWindow(title: "현재 위치"),
        ),
      );

      // 3km 반경 원 업데이트
      circles.clear();
      circles.add(
        Circle(
          circleId: const CircleId('currentLocationRadius'),
          center: location,
          radius: 3000, // 3km를 미터 단위로
          fillColor: Colors.purple.withOpacity(0.0), // 투명 채우기
          strokeColor: Color.fromARGB(255, 111, 0, 255)
              .withOpacity(0.2), // 80% 투명도의 보라색 테두리
          strokeWidth: 2,
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
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _handleLocationUpdate(LatLng(position.latitude, position.longitude));
      },
      onError: (e) {
        debugPrint('위치 스트림 에러: $e');
      },
    );
  }

  // 지도를 새로고침하는 함수
  Future<void> _refreshMap() async {
    if (_isLoading) return;

    if (_currentLocationType == 'small') {
      await _loadNearbyPhotos();
    } else {
      await _loadRepresentativePhotos();
    }

    // 새로고침 후 현재 위치를 마지막 새로고침 위치로 저장
    if (currentLocation != null) {
      _lastRefreshLocation = currentLocation;
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

  // 필터 업데이트 메서드 추가
  Future<void> _updateUserFilter(
      String sort, String period, int startDatetime, int endDatetime) async {
    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        await _userService.updateFilter(
          userId: userId,
          sort: '좋아요순',
          period: period,
          startDatetime: startDatetime,
          endDatetime: endDatetime,
        );
        _refreshMap(); // 필터 업데이트 후 지도 새로고침
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('필터 업데이트 실패: $e')),
        );
      }
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
                    _refreshMap();
                  }
                },
                onCameraMove: _onCameraMove,
                initialCameraPosition: CameraPosition(
                  target: currentLocation ?? const LatLng(37.5665, 126.9780),
                  zoom: 11.0,
                ),
                markers: markers,
                circles: circles,
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
                      onTagsSelected: (tags) {
                        setState(() {
                          selectedTags = tags;
                        });
                        _refreshMap(); // 태그 선택 시 _refreshMap 호출
                      },
                      onFilterUpdate:
                          (sort, period, startDatetime, endDatetime) {
                        _updateUserFilter(
                            sort, period, startDatetime, endDatetime);
                      },
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

            // Map Screen의 build 메서드에서 Positioned 위젯 추가
            Positioned(
              right: 16,
              bottom: 90,
              child: FloatingActionButton(
                heroTag: 'sendLocation',
                onPressed: () async {
                  if (currentLocation != null) {
                    await _handleLocationUpdate(currentLocation!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('map.dart 현재 위치 재전송 완료')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('현재 위치를 가져올 수 없습니다')),
                    );
                  }
                },
                child: const Icon(Icons.send),
              ),
            ),

            // 오른쪽 하단 새로고침 버튼
            Positioned(
              right: 16,
              bottom: 20,
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
              bottom: 18,
              left: 0,
              right: 0,
              child: Center(
                child:
                    LocationLevelIndicator(locationType: _currentLocationType),
              ),
            )
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
