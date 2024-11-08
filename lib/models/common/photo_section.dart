// title: 사진들 위에 있는 제목들 ex) 좋아요 많이 받은 사진들
// photos: 사진들 
import 'package:picto/models/common/photo.dart';

class PhotoSection{
  final String title;
  final List<Photo> photos;
  final String? description; // 사진 대회의 현재 좋아요 같은 섹션 제목
  final int likes;

  PhotoSection({
    required this.title,
    required this.photos,
    this.description,
    required this.likes,
  });
}