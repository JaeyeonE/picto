import 'package:picto/models/common/status.dart';

class ChatMessage {
  final int folderId;
  final String content;
  final DateTime time;
  final Status status;

  ChatMessage({
    required this.folderId,
    required this.content,
    required this.time,
    required this.status,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      folderId: json['folder_id'],
      content: json['content'],
      time: json['sent_time'],
      status: Status.fromJson(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder_id': folderId,
      'content': content,
      'sent_time': time,
      'status': status.toJson(),
    };
  }
}