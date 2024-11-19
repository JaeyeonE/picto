///Users/jaeyeon/workzone/picto/lib/views/map/map.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:picto/views/map/search_screen.dart';
import '../../widgets/common/map_header.dart';
import '../../widgets/common/tag_list.dart';
import '../../widgets/common/navigation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int selectedIndex = 2;
  String selectedTag = '전체';
  KakaoMapController? mapController;
  LatLng? currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  Set<Marker> markers = {};
  Set<Marker> photoMarkers = {};
  final TextEditingController searchController = TextEditingController();
  final dio = Dio();

  Future<void> _searchPhotos(LatLng location, List<String> tags) async {
    // TODO: API 구현 후 아래의 목업 데이터를 실제 API 호출로 교체
    /* 실제 API 구현 시 사용할 코드
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      final photos = await PhotoApi.getPhotos(
        userId: userId,
        lat: location.latitude,
        lng: location.longitude,
        count: 50,
        tags: tags,
      );

      photoMarkers.clear();
      
      for (var photo in photos) {
        photoMarkers.add(
          Marker(
            markerId: "photo_${photo.photoId}",
            latLng: LatLng(photo.lat, photo.lng),
            markerImageSrc: 'lib/assets/map/photo_marker.png',
            width: 30,
            height: 30,
            infoWindowText: photo.title,
          ),
        );
      }

      setState(() {
        markers = {...markers, ...photoMarkers};
      });
      
      await mapController?.setCenter(location);
      mapController?.addMarker(markers: markers.toList());

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 검색 중 오류가 발생했습니다: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

    */

    // ==================== 임시 목업 데이터 시작 ====================
    try {
      // API 호출 지연 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 500));

      // 목업 데이터
      final Map<String, dynamic> mockResponse = {
        'isSuccess': true,
        'result': [
          {
            'photo_id': '1',
            'lat': location.latitude + 0.001,
            'lng': location.longitude + 0.001,
            'title': '테스트 사진 1',
            'tag': '풍경'
          },
          {
            'photo_id': '2',
            'lat': location.latitude - 0.001,
            'lng': location.longitude - 0.001,
            'title': '테스트 사진 2',
            'tag': '인물'
          },
          {
            'photo_id': '3',
            'lat': location.latitude + 0.002,
            'lng': location.longitude - 0.002,
            'title': '테스트 사진 3',
            'tag': '음식'
          },
        ]
      };

      // 목업 데이터 처리
      if (mockResponse['isSuccess'] == true) {
        photoMarkers.clear();
        final List<dynamic> results = mockResponse['result'] as List<dynamic>;
        for (var photo in results) {
          if (tags.isEmpty || tags.contains(photo['tag'])) {
            photoMarkers.add(
              Marker(
                markerId: "photo_${photo['photo_id']}",
                latLng: LatLng(photo['lat'], photo['lng']),
                markerImageSrc: 'lib/assets/map/photo_marker.png',
                width: 30,
                height: 30,
                // onClick: () {
                //   // TODO: 여기에 페이지 이동 로직 구현
                //   // Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(
                //   //     builder: (context) => DetailScreen(photoId: photo['photo_id']),
                //   //   ),
                //   // );
                // },
              ),
            );
          }
        }

        setState(() {
          markers = {...markers, ...photoMarkers};
        });
        mapController?.addMarker(markers: markers.toList());

        if (mapController != null) {
          mapController!.setCenter(location);
        }
      }
    } catch (e) {
      print('사진 검색 오류: $e');
    }
    // ==================== 임시 목업 데이터 끝 ====================
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _updateMyLocationMarker(LatLng location) {
    markers.removeWhere((marker) => marker.markerId == "myLocation");
    markers.add(
      Marker(
        markerId: "myLocation",
        latLng: location,
        // TODO: 마커 이미지 설정 이슈 해결 필요
        // markerImageSrc: '../../assets/map/refresh_map.png',
        // width: 30,
        // height: 30,
      ),
    );

    if (mapController != null) {
      mapController!.addMarker(markers: markers.toList());
    }
  }

  Future<void> _refreshMap() async {
    // TODO: 새로고침 로직 구현 필요
    setState(() {
      // 마커 상태 업데이트
    });
  }

  Future<void> _startLocationUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
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
      onError: (error) {
        print('실시간 위치 업데이트 오류: $error');
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (mapController != null && currentLocation != null) {
        await mapController!.setCenter(currentLocation!);
        _updateMyLocationMarker(currentLocation!);
      }
    } catch (e) {
      print('위치를 가져오는데 실패했습니다: $e');
    }
  }

  void onTagSelected(String tag) {
    setState(() {
      selectedTag = tag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: (controller) {
              mapController = controller;
              if (currentLocation != null) {
                controller.setCenter(currentLocation!);
                _updateMyLocationMarker(currentLocation!);
              }
            },
            center: currentLocation ?? LatLng(37.5665, 126.9780),
            markers: markers.toList(),
          ),
          Column(
            children: [
              MapHeader(
                onSearchPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => 
                        SearchScreen(
                          onSearch: _searchPhotos,
                          defaultLocation: currentLocation ?? LatLng(37.5665, 126.9780),
                        ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
              TagSelector(
                selectedTag: selectedTag,
                onTagSelected: onTagSelected,
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 100,
            child: InkWell(
              onTap: _refreshMap,
              child: Image.asset(
                'lib/assets/map/refresh_map.png', // 이미지 수정 필요
                width: 56,
                height: 56,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          if (index == 2 && selectedIndex == 2) {
            _getCurrentLocation();
          }
        },
      ),
    );
  }
}