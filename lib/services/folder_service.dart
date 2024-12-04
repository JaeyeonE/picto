import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';

import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';

class FolderService {
  final Dio _dio;
  final String baseUrl;

  FolderService(this._dio) : baseUrl = 'http://3.35.153.213:8081/folder-manager';
  
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