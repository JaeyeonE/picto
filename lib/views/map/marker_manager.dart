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

  // 특정 위치 타입의 마커가 비어있는지 확인
  bool isMarkersEmpty(String locationType) {
    switch (locationType) {
      case 'large':
        return _largeMarkers.isEmpty;
      case 'middle':
        return _middleMarkers.isEmpty;
      case 'small':
        return _smallMarkers.isEmpty;
      default:
        return true;
    }
  }

  // 현재 사용하지 않는 마커 세트 정리
  void clearUnusedMarkers(String currentLocationType) {
    switch (currentLocationType) {
      case 'large':
        _middleMarkers.clear();
        _smallMarkers.clear();
        break;
      case 'middle':
        _largeMarkers.clear();
        _smallMarkers.clear();
        break;
      case 'small':
        _largeMarkers.clear();
        _middleMarkers.clear();
        break;
    }
    _updateAllMarkers();
  }

  // 마커 생성 및 저장
  Future<Set<Marker>> createMarkersFromPhotos(
      List<Photo> photos, String locationType) async {
    final newMarkers = <Marker>{};
    final existingMarkerIds = _getExistingMarkerIds(locationType);

    for (var photo in photos) {
      if (photo.lat == null || photo.lng == null) {
        print("Skipping photo due to null coordinates");
        continue;
      }

      final markerId = MarkerId('${locationType}_${photo.photoId}');
      
      // 이미 존재하는 마커인지 확인
      if (existingMarkerIds.contains(markerId.value)) {
        // 기존 마커 재사용
        final existingMarker = _getExistingMarker(locationType, markerId.value);
        if (existingMarker != null) {
          newMarkers.add(existingMarker);
          continue;
        }
      }

      // 새로운 마커 생성
      final markerIcon = await MarkerImageProcessor.createMarkerIcon(
        photo.userId == currentUserId, photo
      );

      final marker = Marker(
        markerId: markerId,
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

    _updateAllMarkers();
    return newMarkers;
  }

  // 특정 위치 타입의 모든 마커 삭제
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

  // 모든 마커 삭제
  void clearAllMarkers() {
    _largeMarkers.clear();
    _middleMarkers.clear();
    _smallMarkers.clear();
    _allMarkers.clear();
  }

  // 전체 마커 세트 업데이트
  void _updateAllMarkers() {
    _allMarkers = {..._largeMarkers, ..._middleMarkers, ..._smallMarkers};
  }

  // 기존 마커 ID 가져오기
  Set<String> _getExistingMarkerIds(String locationType) {
    switch (locationType) {
      case 'large':
        return _largeMarkers.map((m) => m.markerId.value).toSet();
      case 'middle':
        return _middleMarkers.map((m) => m.markerId.value).toSet();
      case 'small':
        return _smallMarkers.map((m) => m.markerId.value).toSet();
      default:
        return {};
    }
  }

  // 기존 마커 가져오기
  Marker? _getExistingMarker(String locationType, String markerId) {
    Set<Marker> markers;
    switch (locationType) {
      case 'large':
        markers = _largeMarkers;
        break;
      case 'middle':
        markers = _middleMarkers;
        break;
      case 'small':
        markers = _smallMarkers;
        break;
      default:
        return null;
    }
    try {
      return markers.firstWhere((m) => m.markerId.value == markerId);
    } catch (e) {
      return null;
    }
  }

  // 특정 위치 타입의 마커 가져오기
  Set<Marker> getMarkersByType(String locationType) {
    switch (locationType) {
      case 'large':
        return _largeMarkers;
      case 'middle':
        return _middleMarkers;
      case 'small':
        return _smallMarkers;
      default:
        return {};
    }
  }

  // 모든 마커 가져오기
  Set<Marker> getAllMarkers() {
    return _allMarkers;
  }
}