import 'package:dio/dio.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/user_manager/api_exceptions.dart';
import '../models/photo_manager/photo_requests.dart';

class PhotoManagerService {
  final Dio _dio;
  static const String _servicePath = '/photo-manager';

  PhotoManagerService({required String host}) 
    : _dio = Dio(BaseOptions(
        baseUrl: '$host$_servicePath',
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ));

  // 지역 대표 사진 조회
  Future<List<Photo>> getRepresentativePhotos(RepresentativePhotoRequest request) async {
    try {
      final response = await _dio.get(
        '/photos/representative',
        data: request.toJson(),
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
      );
      
      return (response.data as List)
        .map((json) => Photo.fromJson(json))
        .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 특정 사진 조회
  Future<List<Photo>> getPhotos(PhotoQueryRequest request) async {
    try {
      final response = await _dio.get(
        '/photos',
        data: request.toJson(),
      );
      
      return (response.data as List)
        .map((json) => Photo.fromJson(json))
        .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 좋아요 추가
  Future<void> likePhoto(PhotoActionRequest request) async {
    try {
      await _dio.post(
        '/photos/like',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 좋아요 취소
  Future<void> unlikePhoto(PhotoActionRequest request) async {
    try {
      await _dio.delete(
        '/photo/unlike',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 사진 조회 기록
  Future<void> viewPhoto(PhotoActionRequest request) async {
    try {
      await _dio.post(
        '/photos/view',
        data: request.toJson(),
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