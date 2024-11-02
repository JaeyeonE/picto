import 'package:picto/models/common/user.dart';

class MutedList {
  final User userList;
  final bool muted;
  
  MutedList({
    required this.userList,
    required this.muted,
  });
}