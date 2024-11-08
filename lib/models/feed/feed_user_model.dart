import 'package:picto/models/common/photo.dart';
import 'package:picto/models/common/user.dart';

class FeedUser{
  final User user;
  final Photo photolist;

  FeedUser({
    required this.user,
    required this.photolist,
  });
}