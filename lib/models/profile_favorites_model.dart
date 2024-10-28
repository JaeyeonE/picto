import 'package:picto/models/user_info.dart';

class ProfileFavoritesModel {
  final UserInfo userList;
  final bool isFavorite;

  ProfileFavoritesModel({
    required this.userList,
    required this.isFavorite,
  });
}