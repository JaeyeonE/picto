// // lib/services/user_manager.dart
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../models/user_modles.dart';

// class UserManager {
//   static const String baseUrl = 'YOUR_BASE_URL';
//   static const Map<String, String> headers = {
//     'Content-Type': 'application/json',
//   };

//   // 로그인
//   Future<LoginResponse> login(LoginRequest request) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/login'),
//         headers: headers,
//         body: jsonEncode(request.toJson()),
//       );

//       if (response.statusCode == 200) {
//         final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
//         // 토큰 저장
//         await _saveToken(loginResponse.accessToken);
//         return loginResponse;
//       } else if (response.statusCode == 404) {
//         throw Exception('사용자를 찾을 수 없습니다.');
//       } else {
//         throw Exception('로그인 실패: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('로그인 오류: $e');
//     }
//   }

//   // 회원가입
//   Future<SignUpResponse> signUp(SignUpRequest request) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/signup'),
//         headers: headers,
//         body: jsonEncode(request.toJson()),
//       );

//       if (response.statusCode == 200) {
//         return SignUpResponse.fromJson(jsonDecode(response.body));
//       } else if (response.statusCode == 406) {
//         throw Exception('회원가입 실패: 유효하지 않은 요청입니다.');
//       } else {
//         throw Exception('회원가입 실패: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('회원가입 오류: $e');
//     }
//   }

//   // 이메일 중복 확인
//   Future<bool> checkEmail(EmailCheckRequest request) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/check-email'),
//         headers: headers,
//         body: jsonEncode(request.toJson()),
//       );

//       if (response.statusCode == 200) {
//         final checkResponse = EmailCheckResponse.fromJson(jsonDecode(response.body));
//         return checkResponse.result;
//       } else if (response.statusCode == 406) {
//         throw Exception('이미 사용 중인 이메일입니다.');
//       } else {
//         throw Exception('이메일 확인 실패: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('이메일 확인 오류: $e');
//     }
//   }

//   // 토큰 저장
//   Future<void> _saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('accessToken', token);
//   }

//   // 토큰 가져오기
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('accessToken');
//   }

//   // 토큰 삭제 (로그아웃)
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('accessToken');
//   }
// }
