import 'package:dio/dio.dart';
import 'package:picto/models/folder/invite_model.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';
import 'package:picto/services/folder_upload_model.dart';

class FolderService {
  final Dio _dio;
  final String baseUrl;
  final int userId;

  FolderService({required this.userId})
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          validateStatus: (status) => status! < 500,
        )),
        baseUrl = 'http://52.78.237.242:8081/folder-manager';

  Future<FolderModel> createFolder(int userId, String name, String content) async {
    print('Creating folder - Name: $name, Content: $content');
    try {
      final response = await _dio.post(
        '$baseUrl/folders',
        data: {
          'generatorId': userId,
          'name': name,
          'content': content,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print('Folder created successfully: ${response.data}');
      return FolderModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Error creating folder: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<FolderModel> updateFolder(int? userId, int? folderId, String name, String content) async {
    print('Updating folder - ID: $folderId, Name: $name, Content: $content');
    try {
      final response = await _dio.patch(
        '$baseUrl/folders/$folderId',
        queryParameters: {
          'generatorId': userId,
        },
        data: {
          'name': name,
          'content': content,
        },
      );
      print('Folder updated successfully: ${response.data}');
      return FolderModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Error updating folder: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<void> deleteFolder(int userId, int? folderId) async {
    print('Deleting folder - ID: $folderId');
    try {
      if (folderId == null) throw ArgumentError('folderId cannot be null');
      await _dio.delete(
        '$baseUrl/folders/$folderId',
        queryParameters:{
          'generatorId': userId,
        }
      );
      print('Folder deleted successfully');
    } on DioException catch (e) {
      print('Error deleting folder: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<List<FolderModel>> getFolders(int? userId) async {
    print('Fetching folders for user: $userId');
    try {
      final response = await _dio.get('$baseUrl/folders/shares/users/$userId');
      if (response.data is! List) {
        print('Error: Server response is not a list');
        throw FormatException('Expected list response from server');
      }
      final List<dynamic> data = response.data;
      print('Successfully fetched ${data.length} folders');
      return data.map((json) => FolderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error fetching folders: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<List<FolderUser>> getFolderUsers(int userId, int? folderId) async {
    print('Fetching users for folder: $folderId');
    try {
      final response = await _dio.get(
        '$baseUrl/folders/shares/$folderId',
        queryParameters: {
          'userId': userId,
        },
      );
      if (response.data is! List) {
        print('Error: Server response is not a list');
        throw FormatException('Expected list response from server');
      }
      final List<dynamic> data = response.data;
      print('Successfully fetched ${data.length} folder users');
      return data.map((json) => FolderUser.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error fetching folder users: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<void> inviteToFolder(int senderId, int receiverId, int folderId) async {
    print('Inviting user to folder - SenderId: $senderId, ReceiverId: $receiverId, FolderId: $folderId');
    try {
      await _dio.post(
        '$baseUrl/folders/shares',
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'folderId': folderId,
        },
      );
      print('Successfully sent folder invitation');
    } on DioException catch (e) {
      print('Error sending folder invitation: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<void> acceptInvitation(int noticeId, int receiverId, bool isAccepted) async {
    try {
      await _dio.post(
        '$baseUrl/folders/shares/notices/$noticeId',
        data: {
          'receiverId': receiverId,
          'accept': isAccepted,
        },
      );
    } on DioException catch (e) {
      print('Error accepting invitation: ${e.message}');
      throw _handleDioError(e);
    }
  }

  
  Future<List<Invite>> getInvitations(int receiverId) async {
  try {
    final response = await _dio.get(
      '$baseUrl/folders/shares/notices',
      queryParameters: {
        'receiverId': receiverId,
      },
    );
    
    if (response.data is! List) {
      throw FormatException('Expected list response from server');
    }

    final List<dynamic> notices = response.data;
    final invites = notices.map((notice) => Invite.fromJson(notice)).toList();
    
    print('Fetched ${invites.length} invitations');
    return invites;
    
  } on DioException catch (e) {
    print('Error getting invitations: ${e.message}');
    throw _handleDioError(e);
  } catch (e) {
    print('Unexpected error getting invitations: $e');
    throw Exception('Failed to fetch invitations');
  }
}

  Future<FolderUploadModel> uploadPhoto(
    int? folderId, 
    int? userId, 
    int? photoId
  ) async {
      print('Uploading photo - FolderID: $folderId, UserID: $userId, PhotoID: $photoId');
      try {
        final response = await _dio.post(
          '$baseUrl/folders/$folderId/photos/upload',
          queryParameters: {'photoId': photoId, 'userId': userId},
        );
        print('Photo uploaded successfully: ${response.data}');
        return response.data;
      } on DioException catch (e) {
        print('Error uploading photo: ${e.message}');
        throw _handleDioError(e);
      }
  }

  Future<void> deletePhoto(int? folderId, int photoId) async {
    print('Deleting photo - FolderID: $folderId, PhotoID: $photoId');
    try {
      if (folderId == null) throw ArgumentError('folderId cannot be null');
      await _dio.delete('$baseUrl/folders/$folderId/photos/$photoId');
      print('Photo deleted successfully');
    } on DioException catch (e) {
      print('Error deleting photo: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<List<Photo>> getPhotos(int userId, int folderId) async {
    print('Fetching photos for folder: $folderId');
    try {
      if (folderId == null) throw ArgumentError('folderId cannot be null');
      final response = await _dio.get(
        '$baseUrl/folders/$folderId/photos',
        queryParameters: {
          'userId': userId
        },
      );
      if (response.data is! List) {
        print('Error: Server response is not a list');
        throw FormatException('Expected list response from server');
      }
      final List<dynamic> data = response.data;
      print('Successfully fetched ${data.length} photos');
      return data.map((json) => Photo.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error fetching photos: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<Photo> getPhotosTest(int? folderId) async {
    print('Fetching photos for folder: $folderId');
    try {
      final response = await _dio.get('$baseUrl/folders/$folderId/photos/');
      print('Successfully fetched photo detail');
      return Photo.fromJson(response.data);
    } on DioException catch (e) {
      print('Error fetching photo detail: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Future<Photo> getPhotoDetail(int folderId, int photoId) async {
    print('Fetching photo detail - FolderID: $folderId, PhotoID: $photoId');
    try {
      final response = await _dio.get('$baseUrl/folders/$folderId/photos/$photoId');
      print('Successfully fetched photo detail');
      return Photo.fromJson(response.data);
    } on DioException catch (e) {
      print('Error fetching photo detail: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    final error = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => TimeoutException('Connection timed out'),
      DioExceptionType.connectionError => const SocketException('Connection error occurred'),
      DioExceptionType.badResponse => Exception('Server error (${e.response?.statusCode}): ${e.response?.data['message'] ?? 'Unknown error occurred'}'),
      _ => Exception('Network error occurred: ${e.message}'),
    };
    print('Handled error: ${error.toString()}');
    return error;
  }
}