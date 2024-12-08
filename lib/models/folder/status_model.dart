class Status {
  final bool isRead;
  final bool isDelivered;

  Status({
    required this.isRead,
    required this.isDelivered,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRead': isRead,
      'isDelivered': isDelivered,
    };
  }
}