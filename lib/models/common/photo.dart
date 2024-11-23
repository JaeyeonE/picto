class Photo {
    final int photoId;
    final String photoUrl;
    final String? location;
    final String? title;
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
        photoId: json['photoId'],
        photoUrl: json['photoUrl'],
        location: json['location'],
        title: json['title'],
        lat: json['lat'].toDouble(),
        lng: json['lng'].toDouble(),
        registerTime: json['registerTime'],
        uploadTime: json['uploadTime'],
        likes: json['likes'],
        views: json['views'],
        frameActive: json['frameActive'],
        savedDateTime: json['savedDateTime'],
        generatorId: json['generatorId'],
        userId: json['userId'],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'photoId': photoId,
        'photoUrl': photoUrl,
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