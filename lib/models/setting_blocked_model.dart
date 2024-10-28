import 'package:picto/models/user_info.dart';

class BlockedList {
  final UserInfo userList;
  final bool blocked;
  
  BlockedList({
    required this.userList,
    required this.blocked,
  });
}