// lib/services/session/session.dart

enum WebSocketStatus {
  connected,
  disconnected
}

class SessionMessage {
  final String messageType;
  final int senderId;       
  final double? lat;
  final double? lng;
  final int sendDatetime;
  final int? photoId;

  SessionMessage({
    required this.messageType,
    required this.senderId,  
    this.lat,
    this.lng,
    required this.sendDatetime,
    this.photoId,
  });

  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    return SessionMessage(
      messageType: json['messageType'] ?? json['type'],  // messageType 체크 추가
      senderId: json['senderId'],
      lat: json['lat']?.toDouble() ?? 678,
      lng: json['lng']?.toDouble() ?? 678,
      sendDatetime: json['sendDatetime'],
      photoId: json['photoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageType': messageType,  // type을 messageType으로 변경
      'senderId': senderId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'sendDateTime': sendDatetime,
      if (photoId != null) 'photoId': photoId,
    };
  }
}