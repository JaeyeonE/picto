// lib/views/map/map.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:picto/services/user_manager.dart';
import 'package:picto/widgets/button/makers.dart';
import 'package:picto/widgets/common/actual_tag_list.dart';
import '../../services/photo_service.dart';
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
  final PhotoService _photoService = PhotoService();
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

  Future<void> _loadNearbyPhotos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await UserManager().getCurrentUser();
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      final photos = await _photoService.getPhotosAround(int.parse(currentUser.userId));
      
      setState(() {
        photoMarkers.clear();
        for (final photo in photos) {
          if (selectedTags.contains('전체') || selectedTags.contains(photo.tag)) {
            // 비동기로 마커 생성
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
        final location = LatLng(locations.first.latitude, locations.first.longitude);
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
                                    target: LatLng(location.latitude, location.longitude), // 여기서 위치 정보를 Google Maps LatLng로 사용
                                    zoom: 15,
                                  ),
                                ),
                              );
                              await _loadNearbyPhotos();
                            }
                          },
                          defaultLocation: currentLocation ?? const LatLng(37.5665, 126.9780),
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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:kakao_map_plugin/kakao_map_plugin.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:picto/services/user_manager.dart';
// import 'package:picto/widgets/button/makers.dart';
// import 'package:picto/widgets/common/actual_tag_list.dart';
// import '../../services/photo_service.dart';
// import '../map/search_screen.dart';
// import '../../widgets/common/map_header.dart';
// import '../../widgets/common/navigation.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   int selectedIndex = 2;
//   List<String> selectedTags = ['전체'];
//   KakaoMapController? mapController;
//   LatLng? currentLocation;
//   StreamSubscription<Position>? _positionStreamSubscription;
//   Set<Marker> markers = {};
//   Set<Marker> photoMarkers = {};
//   final PhotoService _photoService = PhotoService();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _startLocationUpdates();
//   }

//   @override
//   void dispose() {
//     _positionStreamSubscription?.cancel();
//     super.dispose();
//   }

//   // 위치 권한 요청 및 확인
//   Future<bool> _handleLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('위치 권한이 거부되었습니다')),
//         );
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.')),
//       );
//       return false;
//     }
//     return true;
//   }

//   // 현재 위치 가져오기
//   Future<void> _getCurrentLocation() async {
//     final hasPermission = await _handleLocationPermission();
//     if (!hasPermission) return;

//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         currentLocation = LatLng(position.latitude, position.longitude);
//       });

//       if (mapController != null && currentLocation != null) {
//         await mapController!.setCenter(currentLocation!);
//         _updateMyLocationMarker(currentLocation!);
//         _loadNearbyPhotos();  // 위치 업데이트 후 주변 사진 로드
//       }
//     } catch (e) {
//       debugPrint('현재 위치를 가져오는데 실패했습니다: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('현재 위치를 가져오는데 실패했습니다')),
//       );
//     }
//   }

//   // 실시간 위치 업데이트
//   Future<void> _startLocationUpdates() async {
//     final hasPermission = await _handleLocationPermission();
//     if (!hasPermission) return;

//     const locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 10,
//     );

//     _positionStreamSubscription = Geolocator.getPositionStream(
//       locationSettings: locationSettings,
//     ).listen(
//       (Position position) {
//         setState(() {
//           currentLocation = LatLng(position.latitude, position.longitude);
//         });
//         _updateMyLocationMarker(currentLocation!);
//       },
//       onError: (e) {
//         debugPrint('위치 스트림 에러: $e');
//       },
//     );
//   }

//   // 현재 위치 마커 업데이트
//   void _updateMyLocationMarker(LatLng location) {
//     markers.removeWhere((marker) => marker.markerId == "myLocation");
//   markers.add(MapMarkers.createMyLocationMarker(location));

//   if (mapController != null) {
//     mapController!.addMarker(markers: markers.toList());
//   }
//   }

//   // 주변 사진 로드
//   Future<void> _loadNearbyPhotos() async {
//   if (_isLoading) return;

//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     final currentUser = await UserManager().getCurrentUser();  // UserManager에서 현재 사용자 정보 가져오기
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('로그인이 필요합니다')),
//       );
//       return;
//     }

//     final photos = await _photoService.getPhotosAround(int.parse(currentUser.userId));
//       setState(() {
//         photoMarkers.clear();
//         for (final photo in photos) {
//           if (selectedTags.contains('전체') || selectedTags.contains(photo.tag)) {
//             final marker = MapMarkers.createPhotoMarker(
//               photo: photo,
//               currentUser: currentUser,
//               onTap: (photo) {
//                 // TODO: 사진 상세 페이지로 이동 << 지원이가 수정해줄 부분
//               },
//             );
//             if (marker != null) {  // null이 아닌 경우에만 추가
//               photoMarkers.add(marker);
//             }
//           }
//         }
//         markers = {...markers, ...photoMarkers};
//       });

//     if (mapController != null) {
//       mapController!.addMarker(markers: markers.toList());
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('사진을 불러오는데 실패했습니다: ${e.toString()}')),
//     );
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }


//   // 지도 새로고침
//   Future<void> _refreshMap() async {
//     await _loadNearbyPhotos();
//   }

//   // 태그 선택 시
//   void onTagsSelected(List<String> tags) {
//     setState(() {
//       selectedTags = tags;
//     });
//     _loadNearbyPhotos();  // 새로운 태그로 사진 다시 로드
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           KakaoMap(
//             onMapCreated: (controller) {
//               mapController = controller;
//               if (currentLocation != null) {
//                 controller.setCenter(currentLocation!);
//                 _updateMyLocationMarker(currentLocation!);
//                 _loadNearbyPhotos();  // 지도 생성 후 주변 사진 로드
//               }
//             },
//             center: currentLocation ?? LatLng(37.5665, 126.9780),
//             markers: markers.toList(),
//           ),
//           Column(
//             children: [
//               MapHeader(
//                 onSearchPressed: () {
//                   Navigator.push(
//                     context,
//                     PageRouteBuilder(
//                       pageBuilder: (context, animation, secondaryAnimation) => 
//                         SearchScreen(
//                           onSearch: (location, tags) async {
//                             // 검색 결과에 따라 지도 중심 이동
//                             if (mapController != null) {
//                               await mapController!.setCenter(location);
//                               await _loadNearbyPhotos();
//                             }
//                           },
//                           defaultLocation: currentLocation ?? LatLng(37.5665, 126.9780),
//                         ),
//                       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                         const begin = Offset(0.0, 1.0);
//                         const end = Offset.zero;
//                         const curve = Curves.easeInOutCubic;
//                         var tween = Tween(begin: begin, end: end)
//                             .chain(CurveTween(curve: curve));
//                         return SlideTransition(
//                           position: animation.drive(tween),
//                           child: child,
//                         );
//                       },
//                       transitionDuration: const Duration(milliseconds: 300),
//                     ),
//                   );
//                 },
//               ),
//               TagSelector(  // 추후 변경된 태그 셀렉터에 맞게 변경해야함!
//                 selectedTags: selectedTags,
//                 onTagsSelected: onTagsSelected,
//               ),
//             ],
//           ),
//           if (_isLoading)
//             const Center(
//               child: CircularProgressIndicator(),
//             ),
//           Positioned(
//             right: 16,
//             bottom: 100,
//             child: InkWell(
//               onTap: _refreshMap,
//               child: Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(28),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(Icons.refresh, size: 30),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: CustomNavigationBar(
//         selectedIndex: selectedIndex,
//         onItemSelected: (index) {
//           setState(() {
//             selectedIndex = index;
//           });
//           if (index == 2 && selectedIndex == 2) {
//             _getCurrentLocation();
//           }
//         },
//       ),
//     );
//   }
// }

