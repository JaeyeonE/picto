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
import 'package:picto/views/map/zoom_position.dart';
import 'package:picto/views/upload/upload.dart';
import 'package:picto/widgets/common/actual_tag_list.dart';
import '../map/search_screen.dart';
import '../../widgets/common/map_header.dart';
import '../../widgets/common/navigation.dart';
import 'marker_manager.dart';

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
  int selectedIndex = 2;
  List<String> selectedFilter = ['전체']; //지도맵 위의 필터
  bool _isLoading = false;
  final _searchController = TextEditingController();

  // 구글맵 관련
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  MarkerManager? _markerManager;

  // 위치 관련
  LatLng? currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _lastRefreshLocation;
  String _currentLocationType = 'large';
  static const double _minimumRefreshDistance = 10.0;

  // 서비스 인스턴스
  final _userService = UserManagerService();
  final _photoService = PhotoManagerService(host: 'http://3.35.153.213:8082');
  final SessionService _sessionService = SessionService();
  late final LocationWebSocketHandler _locationHandler;

  final defaultTags = [
          '강아지', '고양이', '다람쥐', '햄스터', '새', '곤충', 
          '파충류', '해양생물', '물고기', '산', '바다', 
          '호수/강', '들판', '숲', '하늘'
        ];

  // 사용자 데이터
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.initialUser;
    _initializeUser();
    _resetUserTags();
    _initializeLocationServices();
    _locationHandler = LocationWebSocketHandler(_sessionService);

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

        if (distanceInMeters <= 3000) {
          try {
            // getPhotos를 named parameters로 호출
            final photos = await _photoService.getPhotos(
              message.senderId, 
              'Photo', 
              message.photoId!, 
              senderId: message.senderId, 
              eventType: 'Photo', 
              eventTypeId: message.photoId!,
            );

            // 현재 줌 레벨이 small(상세)일 때만 마커 추가
            if (_currentLocationType == 'small' && photos.isNotEmpty) {
              final newMarkers = await _markerManager?.createMarkersFromPhotos(
                  photos, 'small');

              if (newMarkers != null && mounted) {
                setState(() {
                  // 새 마커 추가
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
    mapController?.dispose();
    _positionStreamSubscription?.cancel();
    _searchController.dispose();
    _locationHandler.dispose();
    super.dispose();
  }

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

    // 위치 타입이 변경되었을 때만 새로운 데이터 로드
    if (_currentLocationType != newLocationType) {
      setState(() {
        _currentLocationType = newLocationType;
      });

      // 새로운 위치 타입에 해당하는 데이터가 없을 경우에만 로드
      if (newLocationType == 'small' &&
          _markerManager!.isMarkersEmpty('small')) {
        _loadNearbyPhotos();
      } else if ((newLocationType == 'middle' &&
              _markerManager!.isMarkersEmpty('middle')) ||
          (newLocationType == 'large' &&
              _markerManager!.isMarkersEmpty('large'))) {
        _loadRepresentativePhotos();
      }

      // 사용하지 않는 마커 정리
      _markerManager!.clearUnusedMarkers(newLocationType);
    }

    // 현재 줌 레벨에 맞는 마커 표시
    setState(() {
      markers = _markerManager!.getMarkersForZoomLevel(position.zoom);
    });
  }

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

  // 대표사진 가져오기
  Future<void> _loadRepresentativePhotos() async {
    if (_isLoading || currentUser == null || _markerManager == null) {
      print("로드될 마커가 없습니다. ");
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final photos = await _photoService.getRepresentativePhotos(
        locationType: _currentLocationType,
        count: 10,
      );

      final filteredPhotos = photos
          .where((photo) => 
              (photo.tag != null && defaultTags.contains((photo.tag))))
          .toList();

      final newMarkers = await _markerManager!
          .createMarkersFromPhotos(filteredPhotos, _currentLocationType);

      if (mounted) {
        setState(() {
          markers = newMarkers;
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

  // 근처 사진 가져오기
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
      
      // 디버깅을 위한 로그 추가
      print('Retrieved photos: ${photos.length}');
      print('Selected tags: $selectedFilter');
      print('Default tags: $defaultTags');

      final filteredPhotos = photos
          .where((photo) => 
              (photo.tag != null && defaultTags.contains((photo.tag))))
          .toList();

      print('Filtered photos: ${filteredPhotos.length}');

      final newMarkers = await _markerManager!
          .createMarkersFromPhotos(filteredPhotos, 'small');

      print('Created markers: ${newMarkers.length}');

      if (mounted) {
        setState(() {
          markers = newMarkers;
        });
      }
    } catch (e) {
      print('Error loading photos: $e');
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

  void _updateMyLocationMarker(LatLng location) {
    setState(() {
      markers.removeWhere(
          (marker) => marker.markerId == const MarkerId("myLocation"));
      markers.add(
        Marker(
          markerId: const MarkerId("myLocation"),
          position: location,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: "현재 위치"),
        ),
      );

      circles.clear();
      circles.add(
        Circle(
          circleId: const CircleId('currentLocationRadius'),
          center: location,
          radius: 3000,
          strokeColor: Color.fromARGB(255, 111, 0, 255).withOpacity(0.2),
          strokeWidth: 2,
        ),
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
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

  Future<void> _refreshMap() async {
    if (_isLoading) return;

    if (_currentLocationType == 'small') {
      await _loadNearbyPhotos();
    } else {
      await _loadRepresentativePhotos();
    }

    if (currentLocation != null) {
      _lastRefreshLocation = currentLocation;
    }
  }

  Future<void> _initializeLocationServices() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    await _getCurrentLocation();
    _startLocationUpdates();
    if (mounted) {
      setState(() {});
    }
  }

  void onTagsSelected(List<String> tags) {
    setState(() {
      selectedFilter = tags;
    });
    _loadNearbyPhotos();
  }

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

  // 유저 필터 update !!!! startDatetime 최신화 필요
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
        _refreshMap();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('필터 업데이트 실패: $e')),
        );
      }
    }
  }

  Future<void> _resetUserTags() async {
    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        await _userService.updateTags(
          userId: userId,
          tagNames: defaultTags,
        );
        setState(() {
          selectedFilter = ['전체'];
        });
      }
    } catch (e) {
      debugPrint('태그 초기화 실패: $e');
    }
  }

  // 지도 스택 이 부분을 이애해야 제대로 된 설정가능
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Scaffold(
        body: Stack(
          children: [
            RepaintBoundary(
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
            RepaintBoundary(
              child: Column(
                children: [
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
                  //
                  RepaintBoundary(
                    child: TagSelector(
                      userId: widget.initialUser.userId,
                      selectedTags: selectedFilter,
                      onTagsSelected: (tags) {
                        setState(() {
                          selectedFilter = tags;
                        });
                        _refreshMap();
                      },
                      // 실제 필터 업데이트 함수 정의 startDatetime은?
                      onFilterUpdate:
                          (sort, period, startDatetime, endDatetime) {
                        startDatetime = DateTime.now().millisecondsSinceEpoch;
                        _updateUserFilter(
                            sort, period, startDatetime, endDatetime);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              right: 16,
              bottom: 90,
              child: FloatingActionButton(
                heroTag: 'sendLocation',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UploadScreen()),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 20,
              child: RepaintBoundary(
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
