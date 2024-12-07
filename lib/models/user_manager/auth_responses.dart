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

  LoginResponse(
      {required this.accessToken,
      required this.success,
      this.message,
      required this.userId});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
        accessToken: json['accessToken'],
        success: true,
        message: json['message'],
        userId: json['userId']);
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
  final List<dynamic> titles;
  final List<Photo> photos;
  final List marks; // 현재 비어있음
  final List blocks; // 현재 비어있음
  final List<Folder> folders; 

  UserInfoResponse({
    required this.user,
    required this.filter,
    required this.userSetting,
    required this.tags,
    required this.titles,
    required this.photos,
    required this.marks, // 문제생기면 이거 자료형 때문이다
    required this.blocks,
    required this.folders,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      user: User.fromJson(json['user']),
      filter: UserFilter.fromJson(json['filter']),
      userSetting: UserSettings.fromJson(json['userSetting']),
      tags: (json['tags'] as List).map((tag) => UserTag.fromJson(tag)).toList(),
      titles: json['titles'] as List,
      photos: (json['photos'] as List)
          .map((photo) => Photo.fromJson(photo))
          .toList(),
      marks: json['marks'] as List,
      blocks: json['blocks'] as List, 
      folders: (json['folders'] as List)
          .map((folder) => Folder.fromJson(folder))
          .toList(),
    );
  }
}

class Folder {
  final int folderId;
  final int createdDatetime;
  final String folderName;
  final String folderContent;
  final List<int> members;

  Folder({
    required this.folderId,
    required this.createdDatetime,
    required this.folderName,
    required this.folderContent,
    required this.members,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      folderId: json['folderId'],
      createdDatetime: json['createdDatetime'],
      folderName: json['folderName'],
      folderContent: json['folderContent'],
      members: List<int>.from(json['members']),
    );
  }
}
