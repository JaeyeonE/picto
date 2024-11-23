import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';

import 'package:picto/models/common/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';

class FolderService {
  final Dio _dio;
  final String baseUrl;

  FolderService(this._dio) : baseUrl = 'http://HOST/folder-manager';
  
  // 새로운 폴더를 생성하는 함수
  Future<FolderModel> createFolder(String name, String content) async {
    final response = await _dio.post(
      '$baseUrl/folders',
      data: {
        'name': name,
        'content': content,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return FolderModel.fromJson(response.data);
  }

  // 기존 폴더의 정보를 수정하는 함수
  Future<FolderModel> updateFolder(int folderId, String name, String content) async {
    final response = await _dio.patch(
      '$baseUrl/folders/$folderId',
      data: {
        'name': name,
        'content': content,
      },
    );
    return FolderModel.fromJson(response.data);
  }

  // 특정 폴더를 삭제하는 함수
  Future<void> deleteFolder(int? folderId) async {
    await _dio.delete('$baseUrl/folders/$folderId');
  }

  // 모든 폴더 목록을 조회하는 함수
  Future<List<FolderModel>> getFolders() async {
    final response = await _dio.get('$baseUrl/folders');
    final List<dynamic> data = response.data;
    return data.map((json) => FolderModel.fromJson(json)).toList();
  }

  // 특정 폴더의 사용자 목록을 조회하는 함수
  Future<List<FolderUser>> getFolderUsers(int? folderId) async {
    final response = await _dio.get('$baseUrl/folders/$folderId/users');
    final List<dynamic> data = response.data;
    return data.map((json) => FolderUser.fromJson(json)).toList();
  }

  // 사진 업로드
  Future<void> uploadPhoto(int folderId, File photo, Map<String, dynamic> metadata) async {
    String fileName = photo.path.split('/').last;
    FormData formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photo.path, filename: fileName),
      'metadata': jsonEncode(metadata),  // 위치, 제목 등의 메타데이터
    });

    await _dio.post(
      '$baseUrl/folders/$folderId/photos/upload',
      data: formData,
    );
  }

  Future<void> deletePhoto(int? folderId, int photoId) async {
    await _dio.delete('$baseUrl/folders/$folderId/photos/$photoId');
  }

  // 폴더의 전체 사진 조회 함수
  Future<List<Photo>> getPhotos(int? folderId) async {
    final response = await _dio.get('$baseUrl/folders/$folderId/photos');
    final List<dynamic> data = response.data;
    return data.map((json) => Photo.fromJson(json)).toList();
  }

  // 특정 사진 상세 조회 함수
  Future<Photo> getPhotoDetail(int folderId, int photoId) async {
    final response = await _dio.get('$baseUrl/folders/$folderId/photos/$photoId');
    return Photo.fromJson(response.data);
  }


  // 테스트용 데이터
  Future<List<Photo>> getPhotosTest(String folderName) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      Photo(
        photoId: 21,
        photoUrl: "s3://picto-test-bucket/picto-photos/20210115_104549.jpg",
        location: "대구 중구 동인동가 10-13",
        title: null,
        lat: 35.86992644701487,
        lng: 128.60128031467175,
        registerTime: 1731752705878,
        uploadTime: 1731752705878,
        likes: 1188,
        views: 2745,
        frameActive: false,
      ),
      Photo(
        photoId: 84,
        photoUrl: "s3://picto-test-bucket/picto-photos/20210115_104549.jpg",
        location: "경북 고령군 다산면 호촌리 149-5",
        title: null,
        lat: 35.82745963302326,
        lng: 128.46394045884807,
        registerTime: 1731752714106,
        uploadTime: 1731752714106,
        likes: 3392,
        views: 6649,
        frameActive: false,
      ),
    ];
  }


  Future<List<String>> getFoldersTest() async {
    // 테스트용 딜레이 (실제 API 호출처럼 보이게)
    await Future.delayed(const Duration(seconds: 1));
    
    // 테스트 데이터
    return [
      'PICTO',
      '기록연월',
      '2023 크리스마스',
      '가족여행',
      '친구들',
      '맛집',
      '운동',
      '독서',
      '영화'
    ];
  }
}