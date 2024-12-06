class Photo {
    final int photoId;
    final String photoUrl;
    final String contentType;
    final String? location;
    final String? title;
    final String tag;
    final double lat;
    final double lng;
    final int registerTime;
    final int uploadTime;
    final int likes;
    final int views;
    final bool frameActive;
    final int? savedDateTime;  // 사진 저장 시간
    final int? generatorId;    // 생성기 ID
    final int? userId;         // 사용자 ID

    Photo({
      required this.photoId,
      required this.photoUrl,
      required this.contentType,
      required this.tag,
      this.location,
      this.title,
      required this.lat,
      required this.lng,
      required this.registerTime,
      required this.uploadTime,
      required this.likes,
      required this.views,
      required this.frameActive,
      this.savedDateTime,
      this.generatorId,
      this.userId,
    });

    factory Photo.fromJson(Map<String, dynamic> json) {
      return Photo(
        photoId: json['photoId'] ?? 0,
        photoUrl: json['photoPath'] ?? '',
        contentType: json['contentType'] ?? '',
        tag: json['tag'] ?? '',
        location: json['location'] ?? '',
        title: json['title'] ?? '',
        lat: json['lat']?? 0,
        lng: json['lng'] ?? 0,
        registerTime: json['registerTime'] ?? 0,
        uploadTime: json['uploadTime'] ?? 0,
        likes: json['likes'] ?? 0,
        views: json['views'] ?? 0,
        frameActive: json['frameActive'] ?? false,
        savedDateTime: json['savedDateTime'] ?? 0,
        generatorId: json['generatorId'] ?? 1,
        userId: json['userId'] ?? 1,
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'photoId': photoId,
        'photoPath': photoUrl,
        'tag': tag,
        'contentType': contentType,
        'location': location,
        'title': title,
        'lat': lat,
        'lng': lng,
        'registerTime': registerTime,
        'uploadTime': uploadTime,
        'likes': likes,
        'views': views,
        'frameActive': frameActive,
        'savedDateTime': savedDateTime,
        'generatorId': generatorId,
        'userId': userId,
      };
    }
  }