class User {
  final String userName;
  final String userId;
  final String userBio;
  final String userProfile;
  final String title;
  final bool isPrivate;

  User({
    required this.userName,
    required this.userId,
    required this.userBio,
    required this.userProfile,
    required this.title,
    required this.isPrivate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['userId'].toString(),
    userName: json['userName'],
    userBio: json['userBio'],
    userProfile: json['userProfile'],
    title: json['title'],
    isPrivate: json['isPrivate'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userBio': userBio,
    'userProfile': userProfile,
    'title': title,
    'isPrivate': isPrivate,
  };
}