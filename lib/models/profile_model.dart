import 'package:picto/models/user_manager/user.dart';

class ProfileModel {
  final User user;
  final String photoList; // 사진을 어케 가져와야하는 거지 사진 경로들을 가져오는 건가?

  ProfileModel({
    required this.user,
    required this.photoList,
  });
}