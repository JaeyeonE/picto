//lib/models/user_manager/user.dart

class User {
  final String accountName;      // userName -> accountName
  final String userId;           // userId 유지
  final String intro;           // userBio -> intro
  final String? profilePhotoPath; // userProfile -> profilePhotoPath
  final String name;            // title -> name
  final bool profileActive;     // isPrivate -> profileActive
  final String email;          // 추가 필요
  final String password;       // 추가 필요

  User({
    required this.accountName,
    required this.userId,
    required this.intro,
    this.profilePhotoPath,
    required this.name,
    required this.profileActive,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['userId'].toString(),
    accountName: json['accountName'],
    intro: json['intro'],
    profilePhotoPath: json['profilePhotoPath'],
    name: json['name'],
    profileActive: json['profileActive'],
    email: json['email'],
    password: json['password'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'accountName': accountName,
    'intro': intro,
    'profilePhotoPath': profilePhotoPath,
    'name': name,
    'profileActive': profileActive,
    'email': email,
    'password': password,
  };

  factory User.empty() => User(
  accountName: '',
  userId: '0',
  intro: '',
  profilePhotoPath: null,
  name: '',
  profileActive: false,
  email: '',
  password: '',
);
}
