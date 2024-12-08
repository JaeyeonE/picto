// lib/services/session/session.dart

enum WebSocketStatus {
  connected,
  disconnected
}

class SessionMessage {
  final String messagetype;
  final int senderId;       
  final double? lat;
  final double? lng;
  final String sendDateTime;
  final int? photoId;

  SessionMessage({
    required this.messagetype,
    required this.senderId,  
    this.lat,
    this.lng,
    required this.sendDateTime,
    this.photoId,
  });

  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    return SessionMessage(
      messagetype: json['messageType'] ?? json['type'],  // messageType 체크 추가
      senderId: json['senderId'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      sendDateTime: json['sendDateTime'],
      photoId: json['photoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageType': messagetype,  // type을 messageType으로 변경
      'senderId': senderId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'sendDateTime': sendDateTime,
      if (photoId != null) 'photoId': photoId,
    };
  }
}