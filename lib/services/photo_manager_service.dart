//lib/services/photo_manager_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/user_manager/api_exceptions.dart';
import 'package:picto/utils/logging_interceptor.dart';

class PhotoManagerService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const String _servicePath = '/photo-manager';
  static const String _tokenKey = 'auth_token';

  PhotoManagerService({required String host})
      : _dio = Dio(BaseOptions(
          baseUrl: '$host$_servicePath',
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ))
          ..interceptors.add(LoggingInterceptor()),
        _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // 지역 대표 사진 조회
  Future<List<Photo>> getRepresentativePhotos({
    String? eventType,
    required String locationType,
    String? locationName,
    required int count,
  }) async {
    try {
      final response = await _dio.get(
        '/photos/representative',
        data: {
          if (eventType != null) 'eventType': eventType,
          'locationType': locationType,
          if (locationName != null) 'locationName': locationName,
          'count': count,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return (response.data as List)
          .map((json) => Photo.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 주변 사진 조회
  Future<List<Photo>> getNearbyPhotos(int senderId) async {
    try {
      final response = await _dio.get(
        '/photos/around',
        data: {'senderId': senderId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'senderId': senderId,
          },
        ),
      );

      return (response.data as List)
          .map((json) => Photo.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 특정 사진 조회
  Future<List<Photo>> getPhotos({
    required int senderId,
    required String eventType,
    required int eventTypeId,
  }) async {
    try {
      final response = await _dio.get(
        '/photos',
        data: {
          'senderId': senderId,
          'eventType': eventType,
          'eventTypeId': eventTypeId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return (response.data as List)
          .map((json) => Photo.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 좋아요 추가
  Future<void> likePhoto(int userId, int photoId) async {
    try {
      await _dio.post(
        '/photos/like',
        data: {
          'userId': userId,
          'photoId': photoId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 좋아요 취소
  Future<void> unlikePhoto(int userId, int photoId) async {
    try {
      await _dio.delete(
        '/photos/unlike',
        data: {
          'userId': userId,
          'photoId': photoId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 사진 조회 기록
  Future<void> viewPhoto(int userId, int photoId) async {
    try {
      await _dio.post(
        '/photos/view',
        data: {
          'userId': userId,
          'photoId': photoId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    final response = error.response;
    if (response != null) {
      switch (response.statusCode) {
        case 400:
          return ApiException('잘못된 요청입니다.');
        case 401:
          return UnauthorizedException('인증이 필요합니다.');
        case 403:
          return ForbiddenException('권한이 없습니다.');
        case 404:
          return NotFoundException('사진을 찾을 수 없습니다.');
        default:
          return ServerException('서버 오류가 발생했습니다.');
      }
    }
    return NetworkException('네트워크 오류가 발생했습니다.');
  }
}


// //lib/services/photo_manager_service.dart

// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:picto/models/photo_manager/photo.dart';
// import 'package:picto/models/user_manager/api_exceptions.dart';
// import 'package:picto/utils/logging_interceptor.dart';
// import '../models/photo_manager/photo_requests.dart';

// class PhotoManagerService {
//   final Dio _dio;
//   final FlutterSecureStorage _storage;
//   static const String _servicePath = '/photo-manager';
//   static const String _tokenKey = 'auth_token';

//   PhotoManagerService({required String host}) 
//     : _dio = Dio(BaseOptions(
//         baseUrl: '$host$_servicePath',
//         headers: {'Content-Type': 'application/json'},
//         connectTimeout: const Duration(seconds: 5),
//         receiveTimeout: const Duration(seconds: 3),
//       ))..interceptors.add(LoggingInterceptor()), // 인터셉터 추가
//       _storage = const FlutterSecureStorage();

//   Future<String?> getToken() async {
//     return await _storage.read(key: _tokenKey);
//   }

//   // 지역 대표 사진 조회
//   Future<List<Photo>> getRepresentativePhotos({
//     String? eventType,
//     required String locationType,
//     String? locationName,
//     required int count,
//   }) async {
//     try {
//       final token = await getToken();
//       final queryParams = {
//         if (eventType != null) 'eventType': eventType,
//         'locationType': locationType,
//         if (locationName != null) 'locationName': locationName,
//         'count': count.toString(),
//       };

//       final response = await _dio.get(
//         '/photos/representative',
//         queryParameters: queryParams,  // body 대신 queryParameters 사용
//         options: Options(
//           headers: {
//             'Access-Token': token,
//           },
//         ),
//       );
      
//       return (response.data as List)
//           .map((json) => Photo.fromJson(json))
//           .toList();
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // 주변 사진 조회
//   Future<List<Photo>> getNearbyPhotos(int senderId) async {
//     try {
//       final token = await getToken();
//       final response = await _dio.get(
//         '/photos/around',
//         queryParameters: {'senderId': senderId},  // body 대신 queryParameters 사용
//         options: Options(
//           headers: {
//             'Access-Token': token,
//           },
//         ),
//       );
      
//       return (response.data as List)
//         .map((json) => Photo.fromJson(json))
//         .toList();
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // 특정 사진 조회
//   Future<List<Photo>> getPhotos(PhotoQueryRequest request) async {
//     try {
//       final token = await getToken();
//       final response = await _dio.get(
//         '/photos',
//         queryParameters: request.toJson(),  // body 대신 queryParameters 사용
//         options: Options(
//           headers: {
//             'Access-Token': token,
//           },
//         ),
//       );
      
//       return (response.data as List)
//         .map((json) => Photo.fromJson(json))
//         .toList();
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // 좋아요 추가
//   Future<void> likePhoto(PhotoActionRequest request) async {
//     try {
//       final token = await getToken();
//       await _dio.post(
//         '/photos/like',
//         data: request.toJson(),
//         options: Options(
//           headers: {
//             'Access-Token': token,
//           },
//         ),
//       );
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // 좋아요 취소
//   Future<void> unlikePhoto(PhotoActionRequest request) async {
//     try {
//       final token = await getToken();
//       await _dio.delete(
//         '/photo/unlike',
//         data: request.toJson(),
//         options: Options(
//           headers: {
//             'Access-Token': token,
//           },
//         ),
//       );
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // 사진 조회 기록
//   Future<void> viewPhoto(PhotoActionRequest request) async {
//     try {
//       final token = await getToken();
//       await _dio.post(
//         '/photos/view',
//         data: request.toJson(),
//         options: Options(
//           headers: {
//             'Access-Token': token,
//           },
//         ),
//       );
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   ApiException _handleError(DioException error) {
//     final response = error.response;
//     if (response != null) {
//       switch (response.statusCode) {
//         case 400:
//           return ApiException('잘못된 요청입니다.');
//         case 401:
//           return UnauthorizedException('인증이 필요합니다.');
//         case 403:
//           return ForbiddenException('권한이 없습니다.');
//         case 404:
//           return NotFoundException('사진을 찾을 수 없습니다.');
//         default:
//           return ServerException('서버 오류가 발생했습니다.');
//       }
//     }
//     return NetworkException('네트워크 오류가 발생했습니다.');
//   }
// }