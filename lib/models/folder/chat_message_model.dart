class ChatMessage {
  final int folderId;
  final String content;
  final DateTime sendDateTime;
  final String messageType;
  final int senderId;

  ChatMessage({
    required this.folderId,
    required this.content,
    required this.sendDateTime,
    required this.messageType,
    required this.senderId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      folderId: json['folderId'],
      content: json['content'] ?? '',
      sendDateTime: json['sendDatetime'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['sendDatetime'])
          : DateTime.parse(json['sendDatetime']),
      messageType: json['messageType'],
      senderId: json['senderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folderId': folderId,
      'content': content,
      'sendDatetime': sendDateTime.millisecondsSinceEpoch,
      'messageType': messageType,
      'senderId': senderId,
    };
  }
}