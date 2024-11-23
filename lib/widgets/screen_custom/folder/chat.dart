import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Text('채팅'),
      );
  }
}
