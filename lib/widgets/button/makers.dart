// lib/widgets/map/markers.dart
// 카카오맵형 마커(your picto, my picto). 구글형 마커로 수정 필요함.

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:picto/models/common/photo.dart';
import '../../models/common/user.dart';

class MapMarkers {
  static Marker? createPhotoMarker({
    required Photo photo,
    required User currentUser,
    required Function(Photo) onTap,
  }) {
    if (photo.lat == null || photo.lng == null) return null;
    
    final isMyPhoto = photo.userId == currentUser.userId;
    
    return Marker(
      markerId: "${isMyPhoto ? 'my' : 'other'}_photo_${photo.photoId}",
      latLng: LatLng(photo.lat!, photo.lng!),
      markerImageSrc: isMyPhoto 
        ? 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_yellow.png'
        : 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_blue.png',
      width: 40,
      height: 40,
      infoWindowContent: """
        <div style='padding: 5px'>
          <div>${photo.location ?? '위치 정보 없음'}</div>
          <div>${isMyPhoto ? '내 사진' : ''}</div>
          <div>좋아요: ${photo.likes}</div>
          <div>조회수: ${photo.views}</div>
          <div>${photo.tag != null ? '#${photo.tag}' : ''}</div>
        </div>
      """,
    );
  }

  static Marker createMyLocationMarker(LatLng location) {
    return Marker(
      markerId: "myLocation",
      latLng: location,
      markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
      width: 40,
      height: 40,
    );
  }

  static Marker? createMyPhotoMarker({
    required Photo photo,
    required Function(Photo) onTap,
  }) {
    if (photo.lat == null || photo.lng == null) return null;
    
    return Marker(
      markerId: "my_photo_${photo.photoId}",
      latLng: LatLng(photo.lat!, photo.lng!),
      markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_yellow.png',
      width: 40,
      height: 40,
      infoWindowContent: _createInfoWindow(photo),
    );
  }

  static Marker? createOthersPhotoMarker({
    required Photo photo,
    required Function(Photo) onTap,
  }) {
    if (photo.lat == null || photo.lng == null) return null;
    
    return Marker(
      markerId: "other_photo_${photo.photoId}",
      latLng: LatLng(photo.lat!, photo.lng!),
      markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_blue.png',
      width: 40,
      height: 40,
      infoWindowContent: _createInfoWindow(photo),
    );
  }

  static String _createInfoWindow(Photo photo) {
    return """
      <div style='padding: 5px'>
        <div>${photo.location ?? '위치 정보 없음'}</div>
        <div>좋아요: ${photo.likes}</div>
        <div>조회수: ${photo.views}</div>
        <div>${photo.tag != null ? '#${photo.tag}' : ''}</div>
      </div>
    """;
  }
}