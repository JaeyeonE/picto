class FolderUser {
  final int folderId;
  final int userId;
  final int sharedDateTime;

  FolderUser({
    required this.folderId,
    required this.userId,
    required this.sharedDateTime,
  });

  factory FolderUser.fromJson(Map<String, dynamic> json) {
    return FolderUser(
      folderId: json['folderId'],
      userId: json['userId'],
      sharedDateTime: json['sharedDateTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folderId': folderId,
      'userId': userId,
      'sharedDateTime': sharedDateTime,
    };
  }

}