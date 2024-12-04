// lib/views/map/map.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final _userService = UserManagerService(host: 'http://3.35.153.213:8086');
  final _photoService = PhotoManagerService(host: 'http://3.35.153.213:8082');
  bool _isLoading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    mapController?.dispose();
    _positionStreamSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
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

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (Context) => const UploadScreen()),
            );
          },
        ),
      );
    });
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
              if (currentLocation != null) {
                controller.animateCamera(
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
            },
            initialCameraPosition: CameraPosition(
              target: currentLocation ?? const LatLng(37.5665, 126.9780),
              zoom: 15,
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
