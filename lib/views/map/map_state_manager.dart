// lib/views/map/map_state_manager.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto/models/photo_manager/photo.dart'; // 이거 안 써도 괜찮나...?
import 'package:picto/models/user_manager/auth_responses.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/photo_manager_service.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/views/map/map_marker_temp.dart';
import 'package:picto/widgets/button/makers.dart';

class MapStateManager {
  final PhotoManagerService photoService;
  final UserManagerService userService;
  Set<Marker> markers = {};
  Set<Marker> photoMarkers = {};
  String currentLocationType = 'large';
  bool isLoading = false;
  final Function(String) onError;
  final Function() onStateChanged;

  MapStateManager({
    required this.photoService,
    required this.userService,
    required this.onError,
    required this.onStateChanged,
  });

  void updateLocationType(double zoom) {
    String newLocationType;
    if (zoom >= 15) {
      newLocationType = 'small';
    } else if (zoom >= 12) {
      newLocationType = 'middle';
    } else {
      newLocationType = 'large';
    }

    if (currentLocationType != newLocationType) {
      currentLocationType = newLocationType;
      onStateChanged();
    }
  }

  Future<void> loadRepresentativePhotos(
    User currentUser, List<String> selectedTags) async {
    if (isLoading) return;
    isLoading = true;
    onStateChanged();

    try {
      final photos = await photoService.getRepresentativePhotos(
        locationType: currentLocationType,
        count: 10,
      );

      final newMarkers = <Marker>{};

      await Future.wait(photos
          .where((photo) =>
              selectedTags.contains('전체') || selectedTags.contains(photo.tag))
          .map((photo) async {
        final marker = await MapMarkers.createPhotoMarker(
          photo: photo,
          currentUser: currentUser,
          onTap: (photo) {
            // TODO: 사진 상세 페이지로 이동
          },
        );
        if (marker != null) newMarkers.add(marker);
      }));

      photoMarkers = newMarkers;
      markers = {...markers}..addAll(photoMarkers);
      onStateChanged();
    } catch (e) {
      onError('사진을 불러오는데 실패했습니다: $e');
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

// //임시 더미 마커
//   Future<void> loadRepresentativePhotos(
//       User currentUser, List<String> selectedTags) async {
//     if (isLoading) return;
//     isLoading = true;
//     onStateChanged();

//     try {
//       final dummyMarkers =
//           await MapMarkerTemp.getDummyMarkers(currentLocationType);
//       print('Dummy markers loaded: ${dummyMarkers.length}'); // 추가
//       photoMarkers = dummyMarkers;
//       markers = {...markers}..addAll(photoMarkers);
//       onStateChanged();
//     } catch (e) {
//       print('Error loading markers: $e'); // 추가
//       onError('마커 로드 실패: $e');
//     } finally {
//       isLoading = false;
//       onStateChanged();
//     }
//   }

  void updateMyLocationMarker(LatLng location) {
    markers.removeWhere(
        (marker) => marker.markerId == const MarkerId("myLocation"));
    markers.add(
      Marker(
        markerId: const MarkerId("myLocation"),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "현재 위치"),
      ),
    );
    onStateChanged();
  }

  Future<void> loadNearbyPhotos(
      User currentUser, List<String> selectedTags) async {
    if (isLoading) return;
    isLoading = true;
    onStateChanged();

    try {
      final token = await userService.getToken();
      if (token == null) {
        onError('로그인이 필요합니다');
        return;
      }

      final userInfo =
          await userService.getUserAllInfo(currentUser.userId as int);
      final photos =
          await photoService.getNearbyPhotos(currentUser.userId as int);

      photoMarkers.clear();
      for (final photo in photos) {
        if (selectedTags.contains('전체') || selectedTags.contains(photo.tag)) {
          final marker = await MapMarkers.createPhotoMarker(
            photo: photo,
            currentUser: userInfo.user,
            onTap: (photo) {
              // TODO: 사진 상세 페이지로 이동
            },
          );
          if (marker != null) {
            photoMarkers.add(marker);
            markers = {...markers, ...photoMarkers};
          }
        }
      }
      onStateChanged();
    } catch (e) {
      onError('사진을 불러오는데 실패했습니다: $e');
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }
}
