class Photo {
  final int photoId;
  final int userId;
  String photoPath;
  final double? lat;
  final double? lng;
  final String? location;
  final int registerDatetime;
  final int updateDatetime;
  final bool frameActive;
  final bool sharedActive;
  final int likes;
  final int views;
  final String? tag;

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
    required this.sharedActive,
    required this.likes,
    required this.views,
    this.tag,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photoId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      photoPath: json['photoPath'] as String? ?? ' ',
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      location: json['location'] as String?,
      registerDatetime:
          json['uploadTime'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updateDatetime:
          json['uploadTime'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      frameActive: json['frameActive'] as bool? ?? false, //액자 저장할 때만 true
      sharedActive: json['sharedActive'] as bool? ?? false,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      tag: json['tag'] as String?,
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
    };
  }
}
