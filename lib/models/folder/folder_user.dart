class FolderUser {
  final int folderId;
  final int userId;
  final String name;
  final String email;

  FolderUser({
    required this.folderId,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory FolderUser.fromJson(Map<String, dynamic> json) {
    return FolderUser(
      folderId: json['folderId'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
    );
  }
}