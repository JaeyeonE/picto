import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';

class FolderService {
  final Dio _dio;
  final String baseUrl;

  FolderService(Dio dio)
      : _dio = dio..options = BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          validateStatus: (status) => status! < 500,
        ),
        baseUrl = 'http://HOST/folder-manager';

  // 새로운 폴더를 생성하는 함수
  Future<FolderModel> createFolder(String name, String content) async {
    try {
      final response = await _dio.post(
        '$baseUrl/folders',
        data: {
          'name': name,
          'content': content,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return FolderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 기존 폴더의 정보를 수정하는 함수
  Future<FolderModel> updateFolder(int folderId, String name, String content) async {
    try {
      final response = await _dio.patch(
        '$baseUrl/folders/$folderId',
        data: {
          'name': name,
          'content': content,
        },
      );
      return FolderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 특정 폴더를 삭제하는 함수
  Future<void> deleteFolder(int? folderId) async {
    try {
      if (folderId == null) throw ArgumentError('folderId cannot be null');
      await _dio.delete('$baseUrl/folders/$folderId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 모든 폴더 목록을 조회하는 함수
  Future<List<FolderModel>> getFolders(int? userId) async {
    try {
      final response = await _dio.get('$baseUrl/folders/shares/users/$userId');
      if (response.data is! List) {
        throw FormatException('Expected list response from server');
      }
      final List<dynamic> data = response.data;
      return data.map((json) => FolderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 특정 폴더의 사용자 목록을 조회하는 함수
  Future<List<FolderUser>> getFolderUsers(int? folderId) async {
    try {
      final response = await _dio.get('$baseUrl/folders/shares/$folderId');
      if (response.data is! List) {
        throw FormatException('Expected list response from server');
      }
      final List<dynamic> data = response.data;
      return data.map((json) => FolderUser.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 폴더 공유하기
  Future<void> shareFolder(int folderId, int senderId, int receiverId) async {
    try {
      await _dio.post('$baseUrl/folders/shares', data: {
        'senderId': senderId,
        'receiverId': receiverId,
        'folderId': folderId
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 사진 업로드
  Future<void> uploadPhoto(int folderId, File photo, Map<String, dynamic> metadata) async {
    try {
      String fileName = photo.path.split('/').last;
      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path, filename: fileName),
        'metadata': jsonEncode(metadata),
      });

      await _dio.post(
        '$baseUrl/folders/$folderId/photos/upload',
        data: formData,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 사진 삭제
  Future<void> deletePhoto(int? folderId, int photoId) async {
    try {
      if (folderId == null) throw ArgumentError('folderId cannot be null');
      await _dio.delete('$baseUrl/folders/$folderId/photos/$photoId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 폴더의 전체 사진 조회 함수
  Future<List<Photo>> getPhotos(int? folderId) async {
    try {
      if (folderId == null) throw ArgumentError('folderId cannot be null');
      final response = await _dio.get('$baseUrl/folders/$folderId/photos');
      if (response.data is! List) {
        throw FormatException('Expected list response from server');
      }
      final List<dynamic> data = response.data;
      return data.map((json) => Photo.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 특정 사진 상세 조회 함수
  Future<Photo> getPhotoDetail(int folderId, int photoId) async {
    try {
      final response = await _dio.get('$baseUrl/folders/$folderId/photos/$photoId');
      return Photo.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 에러 처리 헬퍼 함수
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out');
      case DioExceptionType.connectionError:
        return const SocketException('Connection error occurred');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Unknown error occurred';
        return Exception('Server error ($statusCode): $message');
      default:
        return Exception('Network error occurred: ${e.message}');
    }
  }


  // 테스트용 데이터

  // 테스트용 폴더 목록 조회
  Future<List<FolderModel>> getFoldersTest() async {
    // 실제 API 호출처럼 보이도록 지연 추가
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      FolderModel(
        folderId: 1,
        name: "가족 앨범",
        content: "우리 가족의 소중한 순간들",
        createdDateTime: 1731752705878,
        link: "family-album",
      ),
      FolderModel(
        folderId: 2,
        name: "여름 휴가 2023",
        content: "제주도 여행",
        createdDateTime: 1731752705879,
        link: "summer-vacation",
      ),
      FolderModel(
        folderId: 3,
        name: "우리 아이 성장앨범",
        content: "첫 걸음마부터 초등학교까지",
        createdDateTime: 1731752705880,
        link: "baby-growth",
      ),
      FolderModel(
        folderId: 4,
        name: "반려동물",
        content: "멍멍이와 함께한 추억",
        createdDateTime: 1731752705881,
        link: "pets",
      ),
    ];
  }
}