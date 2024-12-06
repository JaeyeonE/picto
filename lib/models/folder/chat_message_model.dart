import 'status_model.dart';

class ChatMessage {
  final int folderId;
  final String content;
  final DateTime sendDateTime;
  final Status status;
  final String messageType;
  final String senderId;
  final String type;

  ChatMessage({
    required this.folderId,
    required this.content,
    required this.sendDateTime,
    required this.status,
    required this.messageType,
    required this.senderId,
    required this.type,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      folderId: json['folderId'],
      content: json['content'] ?? '',
      sendDateTime: DateTime.parse(json['sendDateTime']),
      status: Status.fromJson(json['status'] ?? {}),
      messageType: json['messageType'],
      senderId: json['senderId'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folderId': folderId,
      'content': content,
      'sendDateTime': sendDateTime.toIso8601String(),
      'status': status.toJson(),
      'messageType': messageType,
      'senderId': senderId,
      'type': type,
    };
  }
}