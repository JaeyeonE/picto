import 'package:picto/models/user_manager/user.dart';

class Photo {
  final int photoId;
  final String userId;
  final String photoPath;
  final double? lat;
  final double? lng;
  final String? location;
  final int registerDatetime;
  final int updateDatetime;
  final bool frameActive;
  final int likes;
  final int views;
  final String? tag;
  final User? user; // API 응답에 따라 optional로 변경

  Photo({
    required this.photoId,
    required this.userId,
    required this.photoPath,
    this.lat,
    this.lng,
    this.location,
    required this.registerDatetime,
    required this.updateDatetime,
    required this.frameActive,
    required this.likes,
    required this.views,
    this.tag,
    this.user,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photoId'] as int,
      userId: json['userId'].toString() ?? 'default',
      photoPath: json['photoPath'] as String,
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      location: json['location'] as String?,
      registerDatetime: json['upDatetime'] as int,
      updateDatetime: json['upDatetime'] as int,
      frameActive: json['frame_active'] as bool ?? false, //액자 저장할 때만 true
      likes: json['likes'] as int,
      views: json['views'] as int,
      tag: json['tag'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      if (user != null) 'user': user!.toJson(),
    };
  }
}
