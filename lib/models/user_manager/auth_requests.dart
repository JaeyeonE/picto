// lib/models/user_manager/auth_requests.dart

class EmailCheckRequest {
  final String email;

  EmailCheckRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class SignUpRequest {
  final String email;
  final String password;
  final String name;
  final double lat;
  final double lng;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
    'lat': lat,
    'lng': lng,
  };
}