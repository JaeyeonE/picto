// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController mapController;
//   TextEditingController searchController = TextEditingController();
  
//   // 초기 카메라 위치 (서울시청)
//   CameraPosition initialPosition = CameraPosition(
//     target: LatLng(37.5665, 126.9780),
//     zoom: 14.0,
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: initialPosition,
//             onMapCreated: (GoogleMapController controller) {
//               mapController = controller;
//             },
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//           ),
//           // 검색 바
//           Positioned(
//             top: 40,
//             left: 20,
//             right: 20,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: '장소 검색',
//                   prefixIcon: Icon(Icons.search),
//                   suffixIcon: IconButton(
//                     icon: Icon(Icons.clear),
//                     onPressed: () {
//                       searchController.clear();
//                     },
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(horizontal: 15),
//                 ),
//                 onSubmitted: (value) => _searchPlace(value),
//               ),
//             ),
//           ),
//           // 현재 위치 버튼
//           Positioned(
//             bottom: 30,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: _moveToCurrentLocation,
//               child: Icon(Icons.my_location),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 장소 검색 함수
//   Future<void> _searchPlace(String query) async {
//     try {
//       List<Location> locations = await locationFromAddress(query);
//       if (locations.isNotEmpty) {
//         final lat = locations.first.latitude;
//         final lng = locations.first.longitude;
        
//         final newPosition = CameraPosition(
//           target: LatLng(lat, lng),
//           zoom: 15,
//         );
        
//         mapController.animateCamera(
//           CameraUpdate.newCameraPosition(newPosition),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('장소를 찾을 수 없습니다.')),
//       );
//     }
//   }

//   // 현재 위치로 이동하는 함수
//   Future<void> _moveToCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
      
//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Location permissions are permanently denied');
//       }

//       Position position = await Geolocator.getCurrentPosition();
//       final newPosition = CameraPosition(
//         target: LatLng(position.latitude, position.longitude),
//         zoom: 15,
//       );
      
//       mapController.animateCamera(
//         CameraUpdate.newCameraPosition(newPosition),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('현재 위치를 가져올 수 없습니다.')),
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; ///
import 'package:picto/utils/app_color.dart';
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
  GoogleMapController? mapController;

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
          Container(
            color: AppColors.white,
            child: const Center(
              child: Text('Map Area'),
            ),
          ),
          Column(
            children: [
              const MapHeader(),
              TagSelector(
                selectedTag: selectedTag,
                onTagSelected: onTagSelected,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}