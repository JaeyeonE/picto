import 'package:picto/models/common/user.dart';

class Photo{
  final User user; // 넣을 필요가 있는지 .. 
  final String photo; // 파일 경로
  final String? description; // galler 이달의 ~~~ 텍스트
  final int likes;

  Photo({
    required this.user,
    required this.photo,
    this.description,
    required this.likes,
  });
}