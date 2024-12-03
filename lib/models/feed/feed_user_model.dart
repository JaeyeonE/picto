
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/user_manager/user.dart';

class FeedUser{
  final User user;
  final Photo photolist;

  FeedUser({
    required this.user,
    required this.photolist,
  });
}