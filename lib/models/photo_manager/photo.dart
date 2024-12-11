import 'dart:typed_data';  // 올바른 임포트


class Photo {
  final int photoId;
  final int userId;
  String photoPath;          // S3 파일 경로
  final double? lat;
  final double? lng;
  final String? location;
  final int registerDatetime;
  final int updateDatetime;
  final bool? frameActive;
  final bool? sharedActive;
  final int likes;
  final int views;
  final String? tag;

  // 이미지 표시를 위한 추가 필드
  Uint8List? imageData;      // 실제 이미지 바이너리 데이터
  String? contentType;       // 이미지 타입 (image/jpeg, image/png 등)
  bool isLoading = false;    // 이미지 로딩 상태
  String? errorMessage;      // 에러 발생 시 메시지

  Photo({
    required this.photoId,
    required this.userId,
    required this.photoPath,
    this.lat,
    this.lng,
    this.location,
    required this.registerDatetime,
    required this.updateDatetime,
    this.frameActive,
    this.sharedActive,
    required this.likes,
    required this.views,
    this.tag,
  });

  // 기존 fromJson 메서드는 유지
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photoId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      photoPath: json['photoPath'] as String? ?? ' ',
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      location: json['location'] as String?,
      registerDatetime: json['uploadTime'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updateDatetime: json['uploadTime'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      frameActive: json['frameActive'] as bool? ?? false,
      sharedActive: json['sharedActive'] as bool? ?? false,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      tag: json['tag'] as String?,
    );
  }

  // 기존 toJson 메서드도 유지
  Map<String, dynamic> toJson() => {
    'photoId': photoId,
    'userId': userId,
    'photoPath': photoPath,
    'lat': lat,
    'lng': lng,
    'location': location,
    'registerDatetime': registerDatetime,
    'updateDatetime': updateDatetime,
    'frame_active': frameActive,
    'likes': likes,
    'views': views,
    'tag': tag,
  };
}
