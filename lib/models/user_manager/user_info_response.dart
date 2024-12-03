import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/models/user_manager/user_filter.dart';
import 'package:picto/models/user_manager/user_setting.dart';
import 'package:picto/models/user_manager/user_tag.dart';

class UserInfoResponse {
  final User user;
  final UserFilter filter;
  final UserSettings userSetting;
  final List<UserTag> tags;
  final List<dynamic> titles;  // 타입 확인 필요
  final List<Photo> photos;

  UserInfoResponse({
    required this.user,
    required this.filter,
    required this.userSetting,
    required this.tags,
    required this.titles,
    required this.photos,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      user: User.fromJson(json['user']),
      filter: UserFilter.fromJson(json['filter']),
      userSetting: UserSettings.fromJson(json['userSetting']),
      tags: (json['tags'] as List)
          .map((tag) => UserTag.fromJson(tag))
          .toList(),
      titles: json['titles'] as List,
      photos: (json['photos'] as List)
          .map((photo) => Photo.fromJson(photo))
          .toList(),
    );
  }
}