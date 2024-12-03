import 'package:picto/models/user_manager/user.dart';

class BlockedList {
  final List<User> userList;
  final bool blocked;
  
  BlockedList({
    required this.userList,
    required this.blocked,
  });
}