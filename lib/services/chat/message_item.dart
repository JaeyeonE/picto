

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/folder/chat_message_model.dart';
import '../../viewmodles/folder_view_model.dart';
import '../../widgets/screen_custom/folder/chat.dart';

class MessageItem extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final VoidCallback onDelete;

  const MessageItem({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FolderViewModel에서 senderId를 조회할 때는 정수형으로 비교
    final sender = context.select<FolderViewModel, int>((vm) {
      final user = vm.userProfiles
          .where((u) => u.userId == int.parse(message.senderId.toString()))
          .firstOrNull;
      return user?.userId ?? message.senderId;
    });

    return MessageBubble(
      message: message,
      senderId: sender,
      isCurrentUser: isCurrentUser,  // ChatViewModel에서 이미 계산된 값 사용
      onDelete: onDelete,
    );
  }
}