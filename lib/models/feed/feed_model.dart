import 'package:picto/models/common/photo.dart';
import 'package:picto/models/common/user.dart';

class FeedModel {
  final Photo photo;
  final User user;
  final bool autoRotate; // 사진 올리고 남는 부분, 회전할 경우의 배경화면은 viewmodel에서 처리하기
  
  FeedModel({
    required this.photo,
    required this.user,
    required this.autoRotate,
  });
}