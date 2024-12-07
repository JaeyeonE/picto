// lib/models/User/auth_responses.dart

import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/models/user_manager/user_filter.dart';
import 'package:picto/models/user_manager/user_setting.dart';
import 'package:picto/models/user_manager/user_tag.dart';

class LoginResponse {
  final String accessToken;
  final bool success;
  final String? message;
  final int userId;

  LoginResponse({
    required this.accessToken,
    required this.success,
    this.message,
    required this.userId
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'],
      success: true,
      message: json['message'],
      userId: json['userId']
    );
  }
}

class SignUpResponse {
  final User user;
  final bool success;
  final String? message;

  SignUpResponse({
    required this.user,
    required this.success,
    this.message,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      user: User.fromJson(json),
      success: true,
      message: json['message'],
    );
  }
}

class UserInfoResponse {
  final User user;
  final UserFilter filter;
  final UserSettings userSetting;
  final List<UserTag> tags;
  final List<dynamic> titles;  // 필요한 경우 Title 모델 추가
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