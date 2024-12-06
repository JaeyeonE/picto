//lib/services/user_manager_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:picto/models/user_manager/api_exceptions.dart';
import 'package:picto/models/user_manager/auth_responses.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/models/user_manager/user_requests.dart';
import 'package:picto/utils/logging_interceptor.dart';

class UserManagerService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  UserManagerService({required String host})
      : _dio = Dio(BaseOptions(
          baseUrl: '$host/user-manager',
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ))
          ..interceptors.add(LoggingInterceptor()),
        _storage = const FlutterSecureStorage();

  // 토큰 관리
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _dio.options.headers['Access-Token'] = token;
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      throw UnauthorizedException('토큰이 없습니다. 다시 로그인해주세요.');
    }
    return token;
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
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final userId = response.data['userId'];
      final token = response.data['accessToken'];
      await saveToken(token);
      await saveUserId(userId);

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
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
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

  // 확인해서 추가할 것
  // 이메일 중복 확인
  Future<bool> checkEmailDuplicate(String email) async {
    try {
      await _dio.get('/email/$email');
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 406) {
        //백엔드 코드 미구현. 우선 무조건 true 반환
        return true;
      }
      throw _handleError(e);
    }
  }

  // 사용자 프로필 조회
  Future<User> getUserProfile(int userId) async {
    try {
      final token = await getToken();
      final response = await _dio.get(
        '/user-all/$userId', // 이거 되면 레전드 근데 사용자 프로필 조회하려면 다르게 설정해야함...
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
      );
      if (response.statusCode == 200) {
        // response.data['user']로 변경하여 User 객체 생성
        return User.fromJson(response.data['user']);
      } else {
        throw Exception('사용자 정보 로드 실패: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 사용자 전체 정보 조회
  Future<UserInfoResponse> getUserAllInfo(int userId) async {
    try {
      final token = await getToken();
      final response = await _dio.get(
        '/user-all/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
      );
      return UserInfoResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 사용자 정보 수정
  Future<void> updateUserInfo(UserUpdateRequest request) async {
    try {
      final token = await getToken();
      final userId = await getUserId();

      await _dio.patch(
        '/user',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 사용자 삭제
  Future<void> deleteUser(int userId) async {
    try {
      final token = await getToken();
      await _dio.delete(
        '/user',
        data: {'userId': userId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 즐겨찾기 추가
  Future<void> addBookmark(int sourceId, int targetId) async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      await _dio.patch(
        '/mark',
        data: {
          'sourceId': sourceId,
          'targetId': targetId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 즐겨찾기 해제
  Future<void> removeBookmark(int sourceId, int targetId) async {
    try {
      final token = await getToken();
      final userId = await getUserId();

      await _dio.delete(
        '/mark',
        data: {
          'sourceId': sourceId,
          'targetId': targetId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 차단 추가
  Future<void> addBlock(int sourceId, int targetId) async {
    try {
      final token = await getToken();
      final userId = await getUserId();

      await _dio.patch(
        '/block',
        data: {
          'sourceId': sourceId,
          'targetId': targetId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 차단 해제
  Future<void> removeBlock(int sourceId, int targetId) async {
    try {
      final token = await getToken();
      final userId = await getUserId();

      await _dio.delete(
        '/block',
        data: {
          'sourceId': sourceId,
          'targetId': targetId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
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
      final token = await getToken();
      await _dio.patch(
        '/filter',
        data: {
          'userId': userId,
          'sort': sort,
          'period': period,
          'startDatetime': startDatetime,
          'endDatetime': endDatetime,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
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
      final token = await getToken();
      await _dio.patch(
        '/setting',
        data: {
          'userId': userId,
          'lightMode': lightMode,
          'autoRotation': autoRotation,
          'aroundAlert': aroundAlert,
          'popularAlert': popularAlert,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
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
      final token = await getToken();
      await _dio.put(
        '/tag',
        data: {
          'userId': userId,
          'tagNames': tagNames,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Access-Token': token,
            'User-Id': userId,
          },
        ),
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
