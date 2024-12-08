//lib/models/user_manager/user_info_response.dart

class UserAllInfo {
  final User user;
  final Filter filter;
  final UserSetting userSetting;
  final List<Tag> tags;
  final List<String> titles;
  final List<Photo> photos;
  final List<dynamic> marks;
  final List<dynamic> blocks;
  final List<dynamic> folders;

  UserAllInfo({
    required this.user,
    required this.filter,
    required this.userSetting,
    required this.tags,
    required this.titles,
    required this.photos,
    required this.marks,
    required this.blocks,
    required this.folders,
  });

  factory UserAllInfo.fromJson(Map<String, dynamic> json) {
    return UserAllInfo(
      user: User.fromJson(json['user']),
      filter: Filter.fromJson(json['filter']),
      userSetting: UserSetting.fromJson(json['userSetting']),
      tags: (json['tags'] as List).map((e) => Tag.fromJson(e)).toList(),
      titles: List<String>.from(json['titles']),
      photos: (json['photos'] as List).map((e) => Photo.fromJson(e)).toList(),
      marks: json['marks'] ?? [],
      blocks: json['blocks'] ?? [],
      folders: json['folders'] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'filter': filter.toJson(),
    'userSetting': userSetting.toJson(),
    'tags': tags.map((e) => e.toJson()).toList(),
    'titles': titles,
    'photos': photos.map((e) => e.toJson()).toList(),
    'marks': marks,
    'blocks': blocks,
    'folders': folders,
  };
}

class User {
  final int usreId;
  final String name;
  final String accountName;
  final String email;
  final bool profileActive;
  final String intro;
  final String? profilePath;

  User({
    required this.usreId,
    required this.name,
    required this.accountName,
    required this.email,
    required this.profileActive,
    required this.intro,
    this.profilePath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      usreId: json['usreId'],
      name: json['name'],
      accountName: json['accountName'],
      email: json['email'],
      profileActive: json['profileActive'],
      intro: json['intro'],
      profilePath: json['profilePath'],
    );
  }

  Map<String, dynamic> toJson() => {
    'usreId': usreId,
    'name': name,
    'accountName': accountName,
    'email': email,
    'profileActive': profileActive,
    'intro': intro,
    'profilePath': profilePath,
  };
}

class Filter {
  final String sort;
  final String period;
  final int startDatetime;
  final int endDatetime;

  Filter({
    required this.sort,
    required this.period,
    required this.startDatetime,
    required this.endDatetime,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      sort: json['sort'],
      period: json['period'],
      startDatetime: json['startDatetime'],
      endDatetime: json['endDatetime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'sort': sort,
    'period': period,
    'startDatetime': startDatetime,
    'endDatetime': endDatetime,
  };
}

class UserSetting {
  final bool lightMode;
  final bool autoRotation;
  final bool aroundAlert;
  final bool popularAlert;

  UserSetting({
    required this.lightMode,
    required this.autoRotation,
    required this.aroundAlert,
    required this.popularAlert,
  });

  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
      lightMode: json['lightMode'],
      autoRotation: json['autoRotation'],
      aroundAlert: json['aroundAlert'],
      popularAlert: json['popularAlert'],
    );
  }

  Map<String, dynamic> toJson() => {
    'lightMode': lightMode,
    'autoRotation': autoRotation,
    'aroundAlert': aroundAlert,
    'popularAlert': popularAlert,
  };
}

class Tag {
  final String tagName;

  Tag({required this.tagName});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(tagName: json['tagName']);
  }

  Map<String, dynamic> toJson() => {'tagName': tagName};
}

class Photo {
  final int photoId;
  final int userId;
  final String photoPath;
  final double lat;
  final double lng;
  final String location;
  final int registerDatetime;
  final int updateDatetime;
  final bool frameActive;
  final int likes;
  final int views;
  final String tag;

  Photo({
    required this.photoId,
    required this.userId,
    required this.photoPath,
    required this.lat,
    required this.lng,
    required this.location,
    required this.registerDatetime,
    required this.updateDatetime,
    required this.frameActive,
    required this.likes,
    required this.views,
    required this.tag,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photoId'],
      userId: json['userId'],
      photoPath: json['photoPath'],
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      location: json['location'],
      registerDatetime: json['registerDatetime'],
      updateDatetime: json['updateDatetime'],
      frameActive: json['frame_active'],
      likes: json['likes'],
      views: json['views'],
      tag: json['tag'],
    );
  }

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