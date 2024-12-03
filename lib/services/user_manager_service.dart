// lib/services/user_manager_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:picto/models/user_manager/api_exceptions.dart';
import 'package:picto/models/user_manager/auth_responses.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/models/user_manager/user_requests.dart';


class UserManagerService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  UserManagerService({required String host}) 
    : _dio = Dio(BaseOptions(
        baseUrl: '$host/user-manager',
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      )),
      _storage = const FlutterSecureStorage();

  // 토큰 관리
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _dio.options.headers['Access-Token'] = token;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    _dio.options.headers.remove('Access-Token');
  }

  // UserId 관리
  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
    _dio.options.headers['User-Id'] = userId.toString();
  }

  // 추가로 getUserId도 int로 반환하도록 수정
  Future<int?> getUserId() async {
    final value = await _storage.read(key: _userIdKey);
    return value != null ? int.parse(value) : null;
  }

  // 로그인
  Future<LoginResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/signin',
        data: {
          'email': email,
          'password': password,
        },
      );

      final userId = response.data['userId'];
      final token = response.data['accessToken'];
      await saveToken(token);
      
      return LoginResponse(
        userId: userId,
        accessToken: token,
        success: true,
      );
    } on DioException catch (e) {
      final error = _handleAuthError(e);
      return LoginResponse(
        userId: 404,
        accessToken: 'error',
        success: false,
        message: error.message,
      );
    }
  }

  // 회원가입
  Future<SignUpResponse> signUp({
    required String email,
    required String password,
    required String name,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'lat': lat,
          'lng': lng,
        },
      );

      return SignUpResponse(
        user: User.fromJson(response.data),
        success: true,
      );
    } on DioException catch (e) {
      final error = _handleAuthError(e);
      return SignUpResponse(
        user: User.empty(),
        success: false,
        message: error.message,
      );
    }
  }

  // 이메일 중복 확인
  Future<bool> checkEmailDuplicate(String email) async {
    try {
      await _dio.get('/email/$email');
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 406) {
        return true;
      }
      throw _handleError(e);
    }
  }

  // 사용자 프로필 조회
  Future<User> getUserProfile(int userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 사용자 전체 정보 조회
  Future<UserInfoResponse> getUserAllInfo(int userId) async {
    try {
      final response = await _dio.get('/user-all/$userId');
      return UserInfoResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 사용자 정보 수정
  Future<void> updateUserInfo(UserUpdateRequest request) async {
    try {
      await _dio.patch(
        '/user',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 사용자 삭제
  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete(
        '/user',
        data: {'userId': userId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 즐겨찾기 추가
  Future<void> addBookmark(int sourceId, int targetId) async {
    try {
      await _dio.patch(
        '/mark',
        data: {
          'sourceId': sourceId,
          'targetId': targetId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 즐겨찾기 해제
  Future<void> removeBookmark(int sourceId, int targetId) async {
    try {
      await _dio.delete(
        '/mark',
        data: {
          'sourceId': sourceId,
          'targetId': targetId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 차단 추가
  Future<void> addBlock(int sourceId, int targetId) async {
    try {
      await _dio.patch(
        '/block',
        data: {
          'sourceId': sourceId,
          'targetId': targetId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 차단 해제
  Future<void> removeBlock(int sourceId, int targetId) async {
    try {
      await _dio.delete(
        '/block',
        data: {
          'sourceId': sourceId,
          'targetId': targetId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 필터 수정
  Future<void> updateFilter({
    required int userId,
    required String sort,
    required String period,
    required int startDatetime,
    required int endDatetime,
  }) async {
    try {
      await _dio.patch(
        '/filter',
        data: {
          'userId': userId,
          'sort': sort,
          'period': period,
          'startDatetime': startDatetime,
          'endDatetime': endDatetime,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 설정 수정
  Future<void> updateSettings({
    required int userId,
    required bool lightMode,
    required bool autoRotation,
    required bool aroundAlert,
    required bool popularAlert,
  }) async {
    try {
      await _dio.patch(
        '/setting',
        data: {
          'userId': userId,
          'lightMode': lightMode,
          'autoRotation': autoRotation,
          'aroundAlert': aroundAlert,
          'popularAlert': popularAlert,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 태그 수정
  Future<void> updateTags({
    required int userId,
    required List<String> tagNames,
  }) async {
    try {
      await _dio.put(
        '/tag',
        data: {
          'userId': userId,
          'tagNames': tagNames,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 에러 핸들링
  ApiException _handleAuthError(DioException error) {
    if (error.response?.statusCode == 404) {
      return ApiException('이메일 또는 비밀번호가 잘못되었습니다.');
    }
    if (error.response?.statusCode == 406) {
      return ApiException('이미 사용 중인 이메일입니다.');
    }
    return _handleError(error);
  }

  ApiException _handleError(DioException error) {
    final response = error.response;
    if (response != null) {
      switch (response.statusCode) {
        case 401:
          return UnauthorizedException('인증이 필요합니다.');
        case 403:
          return ForbiddenException('권한이 없습니다.');
        case 404:
          return NotFoundException('요청한 리소스를 찾을 수 없습니다.');
        case 406:
          return ValidationException('잘못된 요청입니다.');
        default:
          return ServerException('서버 오류가 발생했습니다.');
      }
    }
    return NetworkException('네트워크 오류가 발생했습니다.');
  }
}