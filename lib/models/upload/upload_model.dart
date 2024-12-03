import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/user_manager/user.dart';

class UploadModel {
  final List<Photo> photoGallery; // 여기서 선택된 사진은 widget/custom_widget/upload_pic으로
  final List<String> frame; // 데이터베이스에 액자 여부만 있지 액자 위치는 없는데 말해봐야할 듯
  final User user;
  
  UploadModel({
    required this.photoGallery,
    required this.frame,
    required this.user,
  });
}