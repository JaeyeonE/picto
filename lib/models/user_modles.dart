// lib/models/user_models.dart
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String accessToken;

  LoginResponse({required this.accessToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => 
    LoginResponse(accessToken: json['accessToken']);
}

class SignUpRequest {
  final String email;
  final String password;
  final String name;
  final int userId;
  final double lat;
  final double lng;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.userId,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
    'userId': userId,
    'lat': lat,
    'lng': lng,
  };
}

class SignUpResponse {
  final int userId;
  final String password;
  final String name;
  final String email;
  final bool profileActive;
  final String? profilePhotoPath;
  final String intro;
  final String accountName;
  final int id;
  final bool isNew;

  SignUpResponse({
    required this.userId,
    required this.password,
    required this.name,
    required this.email,
    required this.profileActive,
    this.profilePhotoPath,
    required this.intro,
    required this.accountName,
    required this.id,
    required this.isNew,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => SignUpResponse(
    userId: json['userId'],
    password: json['password'],
    name: json['name'],
    email: json['email'],
    profileActive: json['profileActive'],
    profilePhotoPath: json['profilePhotoPath'],
    intro: json['intro'],
    accountName: json['accountName'],
    id: json['id'],
    isNew: json['new'],
  );
}

class EmailCheckRequest {
  final String email;

  EmailCheckRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class EmailCheckResponse {
  final bool result;

  EmailCheckResponse({required this.result});

  factory EmailCheckResponse.fromJson(Map<String, dynamic> json) => 
    EmailCheckResponse(result: json['result']);
}