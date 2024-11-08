// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Location & Maps Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const MapScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   Position? currentPosition;
//   final TextEditingController searchController = TextEditingController();

//   // 초기 카메라 위치 (대구시청)
//   static const CameraPosition initialPosition = CameraPosition(
//     target: LatLng(35.8714, 128.6014),
//     zoom: 14.0,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw 'Location permissions are denied';
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw 'Location permissions are permanently denied';
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high
//       );

//       setState(() {
//         currentPosition = position;
//       });

//       // 현재 위치로 지도 이동
//       if (mapController != null) {
//         mapController!.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               target: LatLng(position.latitude, position.longitude),
//               zoom: 15,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     setState(() {
//       mapController = controller;
//       if (currentPosition != null) {
//         controller.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               target: LatLng(
//                 currentPosition!.latitude,
//                 currentPosition!.longitude,
//               ),
//               zoom: 15,
//             ),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: initialPosition,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             mapToolbarEnabled: false,
//           ),
//           // 검색 바
//           Positioned(
//             top: 40,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.3),
//                     spreadRadius: 1,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: '장소 검색',
//                   border: InputBorder.none,
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.clear),
//                     onPressed: () {
//                       searchController.clear();
//                     },
//                   ),
//                 ),
//                 onSubmitted: (value) {
//                   // TODO: 장소 검색 구현
//                 },
//               ),
//             ),
//           ),
//           // 현재 위치 버튼
//           Positioned(
//             bottom: 30,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: _getCurrentLocation,
//               child: const Icon(Icons.my_location),
//             ),
//           ),
//           // 현재 위치 좌표 표시 (디버깅용, 필요 없으면 제거)
//           if (currentPosition != null)
//             Positioned(
//               bottom: 100,
//               left: 20,
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('위도: ${currentPosition!.latitude.toStringAsFixed(4)}'),
//                     Text('경도: ${currentPosition!.longitude.toStringAsFixed(4)}'),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     mapController?.dispose();
//     searchController.dispose();
//     super.dispose();
//   }
// }

//이 위에 있는건 지도..를 띄우기 위한 것..

import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';
import 'screens/map/map.dart';

void main() {
  runApp(const PhotoSharingApp());
}

class PhotoSharingApp extends StatelessWidget {
  const PhotoSharingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PICTO',
      theme: AppThemeExtension.appTheme,
      home: const MapScreen(),
    );
  }
}