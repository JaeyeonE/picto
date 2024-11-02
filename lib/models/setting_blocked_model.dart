import 'package:picto/models/common/user.dart';

class BlockedList {
  final User userList;
  final bool blocked;
  
  BlockedList({
    required this.userList,
    required this.blocked,
  });
}