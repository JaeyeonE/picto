class SessionMessage {
  final String senderId;
  final String? photoId;
  final DateTime sendDateTime;
  final double? lat;
  final double? lng;
  final String messageType;

  SessionMessage({
    required this.senderId,
    this.photoId,
    required this.sendDateTime,
    this.lat,
    this.lng,
    required this.messageType,
  });

  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    return SessionMessage(
      senderId: json['senderId'],
      photoId: json['photoId'],
      sendDateTime: DateTime.parse(json['sendDateTime']),
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      messageType: json['messageType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'photoId': photoId,
      'sendDateTime': sendDateTime.toIso8601String(),
      'lat': lat,
      'lng': lng,
      'messageType': messageType,
    };
  }
}