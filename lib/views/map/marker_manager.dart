import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'marker_image_processor.dart';

class MarkerManager {
  Set<Marker> _allMarkers = {};
  Set<Marker> _largeMarkers = {};
  Set<Marker> _middleMarkers = {};
  Set<Marker> _smallMarkers = {};
  final int currentUserId;

  MarkerManager({required this.currentUserId});

  // 현재 줌 레벨에 따른 마커 반환
  Set<Marker> getMarkersForZoomLevel(double zoom) {
    if (zoom >= 15) {
      return _smallMarkers; // 읍면동 level
    } else if (zoom >= 12) {
      return _middleMarkers; // 시군구 level
    } else {
      return _largeMarkers; // 도/광역시 level
    }
  }

  // 마커 생성 및 저장
  Future<Set<Marker>> createMarkersFromPhotos(
      List<Photo> photos, String locationType) async {
    final newMarkers = <Marker>{};

    for (var photo in photos) {
      if (photo.lat == null || photo.lng == null) {
        print("Skipping photo due to null coordinates");
        continue;
      }

      final markerIcon = await MarkerImageProcessor.createMarkerIcon(
        photo.photoPath,
        photo.userId == currentUserId,
      );

      print("Marker icon created for photo ${photo.photoId}");

      final marker = Marker(
        markerId: MarkerId('${locationType}_${photo.photoId}'),
        position: LatLng(photo.lat!, photo.lng!),
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: photo.location ?? '위치 정보 없음',
          snippet: photo.tag ?? '',
        ),
      );

      newMarkers.add(marker);
    }

    // 위치 타입에 따라 적절한 Set에 저장
    switch (locationType) {
      case 'large':
        _largeMarkers = newMarkers;
        break;
      case 'middle':
        _middleMarkers = newMarkers;
        break;
      case 'small':
        _smallMarkers = newMarkers;
        break;
    }
    print("Created ${newMarkers.length} markers");
    _allMarkers = {..._largeMarkers, ..._middleMarkers, ..._smallMarkers};
    return newMarkers;
  }

  // 마커 초기화
  void clearMarkers(String locationType) {
    switch (locationType) {
      case 'large':
        _largeMarkers.clear();
        break;
      case 'middle':
        _middleMarkers.clear();
        break;
      case 'small':
        _smallMarkers.clear();
        break;
    }
    _updateAllMarkers();
  }

  void _updateAllMarkers() {
    _allMarkers = {..._largeMarkers, ..._middleMarkers, ..._smallMarkers};
  }

  // 모든 마커 초기화
  void clearAllMarkers() {
    _largeMarkers.clear();
    _middleMarkers.clear();
    _smallMarkers.clear();
    _allMarkers.clear();
  }
}