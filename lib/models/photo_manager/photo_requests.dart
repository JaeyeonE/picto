class RepresentativePhotoRequest {
  final String? eventType;  // 'top' or 'random'
  final String locationType;  // 'large', 'middle', 'small'
  final String? locationName;
  final int count;

  RepresentativePhotoRequest({
    this.eventType,
    required this.locationType,
    this.locationName,
    required this.count,
  });

  Map<String, dynamic> toJson() => {
    if (eventType != null) 'eventType': eventType,
    'locationType': locationType,
    if (locationName != null) 'locationName': locationName,
    'count': count,
  };
}

class PhotoQueryRequest {
  final int senderId;
  final String eventType;  // 'owner', 'user', 'photo'
  final int eventTypeId;

  PhotoQueryRequest({
    required this.senderId,
    required this.eventType,
    required this.eventTypeId,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'eventType': eventType,
    'eventTypeId': eventTypeId,
  };
}

class PhotoActionRequest {
  final int userId;
  final int photoId;

  PhotoActionRequest({
    required this.userId,
    required this.photoId,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'photoId': photoId,
  };
}