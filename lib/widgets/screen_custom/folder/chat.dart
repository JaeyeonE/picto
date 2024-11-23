import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picto/viewmodles/chat_view_model.dart';
import 'package:picto/services/chat_service.dart';
import 'package:picto/models/common/user.dart';
import 'package:picto/viewmodles/folder_view_model.dart';


class Chat extends StatelessWidget {
  final String folderName;
  final String currentUserId;

  Chat({
    required this.folderName,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatViewModel(ChatService())..setCurrentFolder(folderName),
      child: ChatViewContent(currentUserId: currentUserId),
    );
  }
}

class ChatViewContent extends StatelessWidget {
  final String currentUserId;

  ChatViewContent({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        // ChatMessage를 flutter_chat_types의 Message로 변환
        final messages = viewModel.messages.map((msg) {
          return types.TextMessage(
            id: msg.id,
            author: types.User(id: msg.senderId),
            text: msg.message,
            createdAt: msg.timestamp.millisecondsSinceEpoch,
          );
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('Chat'),
          ),
          body: Chat(
            messages: messages,
            onSendPressed: (types.PartialText message) {
              viewModel.sendMessage(
                message.text,
                currentUserId,
              );
            },
            user: types.User(id: currentUserId),
          ),
        );
      },
    );
  }
}