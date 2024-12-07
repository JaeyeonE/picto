import 'package:picto/models/user_manager/user.dart';

class ProfileFavoritesModel {
  final User userList;
  final bool isFavorite;

  ProfileFavoritesModel({
    required this.userList,
    required this.isFavorite,
  });
}