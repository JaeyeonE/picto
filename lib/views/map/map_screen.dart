// // lib/views/map/map_screen.dart
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:picto/models/user_manager/user.dart';
// import 'package:picto/services/photo_manager_service.dart';
// import 'package:picto/services/user_manager_service.dart';
// import 'package:picto/views/map/location_manager.dart';
// import 'package:picto/views/map/map_state_manager.dart';
// import 'package:picto/views/map/search_screen.dart';
// import 'package:picto/views/map/zoom_position.dart';
// import 'package:picto/widgets/common/actual_tag_list.dart';
// import 'package:picto/widgets/common/map_header.dart';
// import 'package:picto/widgets/common/navigation.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late LocationManager locationManager;
//   late MapStateManager mapStateManager;
//   GoogleMapController? mapController;
//   int selectedIndex = 2;
//   List<String> selectedTags = ['전체'];
//   final _userService = UserManagerService(host: 'http://3.35.153.213:8086');
//   final _photoService = PhotoManagerService(host: 'http://3.35.153.213:8082');
//   User? currentUser;
//   LatLng? currentLocation;

//   @override
//   void initState() {
//     super.initState();

//     locationManager = LocationManager(
//       onLocationChanged: (location) {
//         setState(() {
//           currentLocation = location;
//           mapStateManager.updateMyLocationMarker(location);
//         });
//       },
//       onError: _showError,
//     );

//     mapStateManager = MapStateManager(
//       photoService: _photoService,
//       userService: _userService,
//       onError: _showError,
//       onStateChanged: () => setState(() {}),
//     );

//     _loadCurrentUser();
//     _initializeLocationServices();
//   }

//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     mapController?.dispose();
//     locationManager.dispose();
//     super.dispose();
//   }

//   Future<void> _loadCurrentUser() async {
//     try {
//       final userId = await _userService.getUserId();
//       if (userId != null) {
//         final user = await _userService.getUserProfile(userId);
//         setState(() {
//           currentUser = user;
//         });
//       }
//     } catch (e) {
//       _showError('사용자 정보 로드 실패: $e');
//     }
//   }

//   Future<void> _initializeLocationServices() async {
//     await locationManager.getCurrentLocation(context);
//     locationManager.startLocationUpdates(context);
//   }

//   void _onCameraMove(CameraPosition position) {
//     mapStateManager.updateLocationType(position.zoom);
//   }

//   void onTagsSelected(List<String> tags) {
//     setState(() {
//       selectedTags = tags;
//     });
//     mapStateManager.loadNearbyPhotos(currentUser!, selectedTags);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: Scaffold(
//         body: Stack(
//           children: [
//             RepaintBoundary(
//               child: GoogleMap(
//                 onMapCreated: (GoogleMapController controller) {
//                   mapController = controller;
//                   if (currentLocation != null && currentUser != null) {
//                     mapStateManager.loadRepresentativePhotos(
//                         currentUser!, selectedTags);
//                   }
//                 },
//                 onCameraMove: _onCameraMove,
//                 onCameraIdle: () => mapStateManager.loadRepresentativePhotos(
//                     currentUser!, selectedTags),
//                 initialCameraPosition: CameraPosition(
//                   target: currentLocation ?? const LatLng(37.5665, 126.9780),
//                   zoom: 11.0,
//                 ),
//                 markers: mapStateManager.markers,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: false,
//                 zoomControlsEnabled: false,
//                 mapToolbarEnabled: false,
//               ),
//             ),
//             RepaintBoundary(
//               child: Column(
//                 children: [
//                   RepaintBoundary(
//                     child: MapHeader(
//                       onSearchPressed: () {
//                         Navigator.push(
//                           context,
//                           PageRouteBuilder(
//                             pageBuilder:
//                                 (context, animation, secondaryAnimation) =>
//                                     SearchScreen(
//                               onSearch: (location, tags) async {
//                                 if (mapController != null) {
//                                   await mapController!.animateCamera(
//                                     CameraUpdate.newCameraPosition(
//                                       CameraPosition(
//                                         target: LatLng(location.latitude,
//                                             location.longitude),
//                                         zoom: 15,
//                                       ),
//                                     ),
//                                   );
//                                   await mapStateManager.loadNearbyPhotos(
//                                       currentUser!, selectedTags);
//                                 }
//                               },
//                               defaultLocation: currentLocation ??
//                                   const LatLng(37.5665, 126.9780),
//                             ),
//                             transitionsBuilder: (context, animation,
//                                 secondaryAnimation, child) {
//                               const begin = Offset(0.0, 1.0);
//                               const end = Offset.zero;
//                               const curve = Curves.easeInOutCubic;
//                               var tween = Tween(begin: begin, end: end)
//                                   .chain(CurveTween(curve: curve));
//                               return SlideTransition(
//                                 position: animation.drive(tween),
//                                 child: child,
//                               );
//                             },
//                             transitionDuration:
//                                 const Duration(milliseconds: 300),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   RepaintBoundary(
//                     child: TagSelector(
//                       selectedTags: selectedTags,
//                       onTagsSelected: onTagsSelected,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (mapStateManager.isLoading)
//               const Center(child: CircularProgressIndicator()),
//             Positioned(
//               right: 16,
//               bottom: 50,
//               child: RepaintBoundary(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     FloatingActionButton(
//                       heroTag: 'refresh',
//                       onPressed: () => mapStateManager.loadNearbyPhotos(
//                           currentUser!, selectedTags),
//                       child: const Icon(Icons.refresh),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 100,
//               left: 0,
//               right: 0,
//               child: LocationLevelIndicator(
//                   locationType: mapStateManager.currentLocationType),
//             ),
//           ],
//         ),
//         bottomNavigationBar: RepaintBoundary(
//           child: CustomNavigationBar(
//             selectedIndex: selectedIndex,
//             onItemSelected: (index) {
//               setState(() {
//                 selectedIndex = index;
//               });
//               if (index == 2 && selectedIndex == 2) {
//                 locationManager.getCurrentLocation(context);
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
