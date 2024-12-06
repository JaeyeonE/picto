//lib/models/user_manager/user.dart

class User {
  final String? accountName;
  final String userId;
  final String name; 
  final String email; 
  final String? profilePath; 
  final String? intro; 
  final bool profileActive; 
  final String? password; 

  User({
    required this.accountName,
    required this.userId,
    required this.intro,
    required this.profilePath,
    required this.name,
    required this.profileActive,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'].toString(),
        accountName: json['accountName'],
        intro: json['intro'],
        profilePath: json['profilePath'],
        name: json['name'],
        profileActive: json['profileActive'],
        email: json['email'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'accountName': accountName,
        'email': email,
        'profileActive': profileActive,
        'intro': intro,
        'profilePath': profilePath,
        'password': password,
      };

  factory User.empty() => User(
        accountName: 'empty',
        userId: '0',
        intro: 'empty',
        profilePath: 'lib/assets/map/dog.png',
        name: 'empty',
        profileActive: false,
        email: '',
        password: '',
      );
}
