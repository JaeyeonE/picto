import 'package:picto/models/user_info.dart';

class MutedList {
  final UserInfo userList;
  final bool muted;
  
  MutedList({
    required this.userList,
    required this.muted,
  });
}