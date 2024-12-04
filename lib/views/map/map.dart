// lib/views/map/map.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/photo_manager_service.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/views/upload/upload.dart';
import 'package:picto/widgets/button/makers.dart';
import 'package:picto/widgets/common/actual_tag_list.dart';
import '../map/search_screen.dart';
import '../../widgets/common/map_header.dart';
import '../../widgets/common/navigation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int selectedIndex = 2;
  List<String> selectedTags = ['전체'];
  GoogleMapController? mapController;
  LatLng? currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  Set<Marker> markers = {};
  Set<Marker> photoMarkers = {};
  String _currentLocationType = 'large';
  final _userService = UserManagerService(host: 'http://3.35.153.213:8086');
  final _photoService = PhotoManagerService(host: 'http://3.35.153.213:8082');
  bool _isLoading = false;
  final _searchController = TextEditingController();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _initializeLocationServices();
  }

    @override
  void dispose() {
    mapController?.dispose();
    _positionStreamSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // User 정보를 로드하는 함수
  Future<void> _loadCurrentUser() async {
    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        final user = await _userService.getUserProfile(userId);
        setState(() {
          currentUser = user;
        });
      }
    } catch (e) {
      debugPrint('사용자 정보 로드 실패: $e');
    }
    }

  void _onCameraMove(CameraPosition position) {
    String newLocationType;
    if (position.zoom >= 15) {
      newLocationType = 'small';      // 읍/면/동 수준
    } else if (position.zoom >= 12) {
      newLocationType = 'middle';     // 시/군/구 수준
    } else {
      newLocationType = 'large';      // 도/광역시 수준
    }

    if (_currentLocationType != newLocationType) {
      setState(() {
        _currentLocationType = newLocationType;
        _loadRepresentativePhotos();  // 줌 레벨 변경 시 대표 사진 새로 로드
      });
    }
  }

  Future<void> _loadRepresentativePhotos() async {
    if (_isLoading || currentUser == null) return;
    setState(() => _isLoading = true);

    try {
      if (currentUser == null) return;

      final photos = await _photoService.getRepresentativePhotos(
        locationType: _currentLocationType,
        count: 10,
      );

      final newMarkers = <Marker>{};

      // 마커 생성을 한번에 처리
      await Future.wait(
        photos.where((photo) =>
          selectedTags.contains('전체') || selectedTags.contains(photo.tag)
        ).map((photo) async {
          final marker = await MapMarkers.createPhotoMarker(
            photo: photo,
            currentUser: currentUser!,
            onTap: (photo) {
              // TODO: 사진 상세 페이지로 이동
            },
          );
          if (marker != null) newMarkers.add(marker);
        })
      );

      // 상태 업데이트를 한 번만 수행
      if (mounted) {
        setState(() {
          photoMarkers = newMarkers;
          markers = {...markers}..addAll(photoMarkers);
        });
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진을 불러오는데 실패했습니다: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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

  void _updateMyLocationMarker(LatLng location) {
    setState(() {
      markers.removeWhere((marker) => marker.markerId == const MarkerId("myLocation"));
      markers.add(
        Marker(
          markerId: const MarkerId("myLocation"),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "현재 위치"),
        ),
      );
    });
  }

  // Future<void> _getCurrentLocation() async {
  //   final hasPermission = await _handleLocationPermission();
  //   if (!hasPermission) return;

  //   try {
  //     final position = await Geolocator.getCurrentPosition(
  //       locationSettings: const LocationSettings(
  //         accuracy: LocationAccuracy.high,
  //         distanceFilter: 50,  // 50미터로 증가
  //       ),
  //     );

  //     setState(() {
  //       currentLocation = LatLng(position.latitude, position.longitude);
  //     });

  //     if (mapController != null && currentLocation != null) {
  //       await mapController!.animateCamera(
  //         CameraUpdate.newCameraPosition(
  //           CameraPosition(
  //             target: currentLocation!,
  //             zoom: 15,
  //           ),
  //         ),
  //       );
  //       _updateMyLocationMarker(currentLocation!);
  //       _loadNearbyPhotos();
  //     }
  //   } catch (e) {
  //     debugPrint('현재 위치를 가져오는데 실패했습니다: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('현재 위치를 가져오는데 실패했습니다')),
  //     );
  //   }
  // }


  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
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
        
        // currentUser가 있을 때만 더미 마커 생성
        if (currentUser != null) {
          await _createDummyMarker();
        }
      }
    } catch (e) {
      debugPrint('위치 정보 오류: $e');
    }
    }

// 더미 마커 생성을 별도 함수로 분리
Future<void> _createDummyMarker() async {
 if (currentLocation == null) return;
 
 final dummyPhoto = Photo(
   photoId: 1,
   userId: currentUser!.userId,
   photoPath: 'dummy_image_path',
   lat: currentLocation!.latitude,
   lng: currentLocation!.longitude,
   location: '현재 위치',
   registerDatetime: DateTime.now().millisecondsSinceEpoch,
   updateDatetime: DateTime.now().millisecondsSinceEpoch,
   frameActive: false,
   likes: 0,
   views: 0,
   tag: '테스트',
 );

 final marker = await MapMarkers.createPhotoMarker(
   photo: dummyPhoto,
   currentUser: currentUser!,
   onTap: (photo) {
     debugPrint('더미 마커 클릭됨');
   },
 );

 if (marker != null && mounted) {
   setState(() {
     markers.add(marker);
   });
 }
}

  Future<void> _startLocationUpdates() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 30, // 30M 마다 조회하도록 설정. 로그 너무 많이 찍히니까
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

  Future<void> _loadNearbyPhotos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 사용자 정보 가져오기 부분 수정
      final token = await _userService.getToken();
      final userId = await _userService.getUserId();

      if (token == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      // 현재 위치 기반 사진 조회
      final photos = await _photoService.getNearbyPhotos(userId);

      setState(() {
        photoMarkers.clear();
        for (final photo in photos) {
          if (selectedTags.contains('전체') || selectedTags.contains(photo.tag)) {
            // 현재 사용자 정보 조회
            _userService.getUserProfile(userId).then((currentUser) {
              MapMarkers.createPhotoMarker(
                photo: photo,
                currentUser: currentUser,
                onTap: (photo) {
                  // TODO: 사진 상세 페이지로 이동
                },
              ).then((marker) {
                if (marker != null) {
                  setState(() {
                    photoMarkers.add(marker);
                    markers = {...markers, ...photoMarkers};
                  });
                }
              });
            });
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진을 불러오는데 실패했습니다: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMap() async {
    await _loadNearbyPhotos();
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
      selectedTags = tags;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (currentLocation != null && currentUser != null) { // [수정] 위치와 사용자 모두 확인
                _loadRepresentativePhotos();
              }  // 초기 대표 사진 로드
            },
            onCameraMove: _onCameraMove,    // 카메라 이동 감지
            onCameraIdle: _loadRepresentativePhotos,  // 카메라 이동 완료 시 사진 로드
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
          Column(
            children: [
              MapHeader(
                onSearchPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          SearchScreen(
                        onSearch: (location, tags) async {
                          if (mapController != null) {
                            await mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                      location.latitude, location.longitude),
                                  zoom: 15,
                                ),
                              ),
                            );
                            await _loadNearbyPhotos();
                          }
                        },
                        defaultLocation:
                            currentLocation ?? const LatLng(37.5665, 126.9780),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
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
                selectedTags: selectedTags,
                onTagsSelected: onTagsSelected,
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            right: 16,
            bottom: 50,
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
