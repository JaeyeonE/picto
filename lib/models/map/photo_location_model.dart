

import '../common/photo.dart';
class PhotoLocationModel {
  final Photo photo;
  final double lat; // 위도
  final double lng; // 경도
  final DateTime uploadTime;

  PhotoLocationModel({
    required this.photo,
    required this.lat,
    required this.lng,
    required this.uploadTime,
  });
}