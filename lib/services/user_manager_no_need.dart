// // lib/services/user_manager.dart
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user_modles.dart';
// import '../models/user_manager/user.dart';

// class UserManager {
//   static const String baseUrl = 'http://3.35.153.213:8085/user-manager';  
//   static const Map<String, String> headers = {
//     'Content-Type': 'application/json',
//   };

//   // 로그인
//   Future<LoginResponse> login(LoginRequest request) async {
//     try {
//       print('Login request data: ${request.toJson()}');

//       final response = await http.post(
//         Uri.parse('$baseUrl/signin'),
//         headers: headers,
//         body: jsonEncode(request.toJson()),
//       ).timeout(
//         const Duration(seconds: 10),
//         onTimeout: () {
//           throw Exception('서버 응답 시간이 초과되었습니다.');
//         },
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
//         await _saveToken(loginResponse.accessToken);
//         return loginResponse;
//       } else if (response.statusCode == 404) {
//         throw Exception('이메일 또는 비밀번호가 일치하지 않습니다.');
//       } else {
//         final errorBody = jsonDecode(response.body);
//         throw Exception(errorBody['message'] ?? '로그인에 실패했습니다.');
//       }
//     } catch (e) {
//       print('Login error: $e');
//       throw Exception('로그인 오류: $e');
//     }
//   }

//   // 회원가입
//   Future<SignUpResponse> signUp(SignUpRequest request) async {
//     try {
//       print('SignUp request data: ${request.toJson()}');

//       final response = await http.post(
//         Uri.parse('$baseUrl/signup'),
//         headers: headers,
//         body: jsonEncode(request.toJson()),
//       ).timeout(
//         const Duration(seconds: 10),
//         onTimeout: () {
//           throw Exception('서버 응답 시간이 초과되었습니다.');
//         },
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return SignUpResponse.fromJson(jsonDecode(response.body));
//       } else if (response.statusCode == 406) {
//         throw Exception('이미 가입된 이메일입니다.');
//       } else {
//         final errorBody = jsonDecode(response.body);
//         throw Exception(errorBody['message'] ?? '회원가입에 실패했습니다.');
//       }
//     } catch (e) {
//       print('SignUp error: $e');
//       throw Exception('회원가입 오류: $e');
//     }
//   }

//   Future<List<User>> getCurrentUser() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/generator/user'),
//         headers: headers,
//       ).timeout(
//         const Duration(seconds: 10),
//         onTimeout: () {
//           throw Exception('서버 응답 시간이 초과되었습니다.');
//         },
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> jsonList = jsonDecode(response.body);
//         return jsonList.map((json) {
//           return User.fromJson(json);
//         }).toList();
//       } else {
//         print('Failed to get user info: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Get current user error: $e');
//       return [];
//     }
//   }

//   // 이메일 중복 확인
//   Future<bool> checkEmail(EmailCheckRequest request) async {
//     return Future.value(true);
//   }

//   // 인증 코드 검증
//   Future<bool> verifyCode(String email, String code) async {
//     return Future.value(true);
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