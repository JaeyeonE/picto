import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';
import 'package:picto/services/folder_service.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/photo_store.dart';
import 'package:picto/services/user_manager_service.dart';

class FolderViewModel extends GetxController {
  final Future<User> user;
  final Rxn<FolderService> _folderService;
  final PhotoStoreService _photoStoreService;
  final UserManagerService _userManagerService;
  final RxList<FolderModel> _folders = RxList([]);
  final RxList<Photo> _photos = RxList([]);
  final RxList<FolderUser> _folderUsers = RxList([]);
  final RxList<User> _userProfiles = RxList([]);
  final RxBool _isLoading = false.obs;
  final RxnString _currentFolderName = RxnString();
  final RxInt _currentFolderId = 0.obs;
  final RxBool _isPhotoList = true.obs;
  final RxBool _isFirst = true.obs;
  final RxBool _isPhotoMode = true.obs;

  FolderViewModel({
    required this.user,
    required FolderService folderService,
    required PhotoStoreService photoStoreService,
    required UserManagerService userManagerService,
  }) : _folderService = Rxn(folderService),
       _photoStoreService = photoStoreService,
       _userManagerService = userManagerService;

  // Getters
  List<FolderModel> get folders => _folders;
  List<Photo> get photos => _photos;
  List<FolderUser> get folderUsers => _folderUsers;
  List<User> get userProfiles => _userProfiles;
  bool get isLoading => _isLoading.value;
  String? get currentFolderName => _currentFolderName.value;
  int get currentFolderId => _currentFolderId.value;
  bool get isPhotoList => _isPhotoList.value;
  bool get isFirst => _isFirst.value;
  bool get isPhotoMode => _isPhotoMode.value;

  // 폴더 목록 로드
  Future<void> loadFolders() async {
    _isLoading.value = true;
    try {
      final folders = await _folderService.value?.getFolders(user.userId);
      print('Loaded folders: ${folders?.map((f) => f.toJson())}');  // 로깅 추가
      _folders.assignAll(folders ?? []);
    } catch (e) {
      print('Error loading folders: $e');
      _folders.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  // 폴더 생성
  Future<void> createFolder(String name, String content) async {
    _isLoading.value = true;
    try {
      final newFolder = await _folderService.value?.createFolder(user.userId, name, content);
      if (newFolder != null) {
        _folders.add(newFolder);
        print('created folder: ${newFolder.toJson()}'); 
      }
    } catch (e) {
      print('Error creating folder: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 폴더 수정
  Future<void> updateFolder(int? folderId, String name, String content) async {
    _isLoading.value = true;
    print('current folder ID: ${folderId}');
    try {
      final updatedFolder = await _folderService.value?.updateFolder(user.userId, folderId, name, content);
      if (updatedFolder != null) {
        final index = _folders.indexWhere((folder) => folder.folderId == folderId);
        if (index != -1) {
          _folders[index] = updatedFolder;
        }
        print('updated folder: ${updatedFolder.toJson()}');
      }
    } catch (e) {
      print('Error updating folder: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 폴더 삭제
  Future<void> deleteFolder(int folderId) async {
    _isLoading.value = true;
    try {
      await _folderService.value?.deleteFolder(user.userId, folderId);
      _folders.removeWhere((folder) => folder.folderId == folderId);
    } catch (e) {
      print('Error deleting folder: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 폴더 내 사진 목록 로드
  Future<void> loadPhotos(int folderId) async {
    _isLoading.value = true;
    try {
      final photos = await _folderService.value?.getPhotos(user.userId, folderId);
      if (photos != null) {
        // 각 사진에 대해 PhotoStore에서 실제 이미지 데이터 다운로드
        for (var photo in photos) {
          try {
            final response = await _photoStoreService.downloadPhoto(photo.photoId.toString());
            if (response.statusCode == 200) {
              photo.photoPath = response.body; // 실제 이미지 데이터 또는 URL을 저장
            }
          } catch (e) {
            print('Error downloading photo ${photo.photoId}: $e');
          }
        }
        _photos.assignAll(photos);
      } else {
        _photos.clear();
      }
      _currentFolderId.value = folderId;
    } catch (e) {
      print('Error loading photos: $e');
      _photos.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  // 폴더 사용자 목록 로드
  Future<void> loadFolderUsers(int? folderId) async {
    _isLoading.value = true;
    try {
      final users = await _folderService.value?.getFolderUsers(user.userId, folderId);
      _folderUsers.assignAll(users ?? []);
      
      // 각 폴더 사용자의 상세 프로필 정보 로드
      _userProfiles.clear();
      for (var folderUser in _folderUsers) {
        try {
          final userProfile = await _userManagerService.getUserProfile(folderUser.userId);
          _userProfiles.add(userProfile);
        } catch (e) {
          print('Error loading user profile for userId ${folderUser.userId}: $e');
        }
      }
    } catch (e) {
      print('Error loading folder users: $e');
      _folderUsers.clear();
      _userProfiles.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  // 사진 업로드
  Future<void> uploadPhoto(int folderId, File photo, Map<String, dynamic> metadata) async {
    _isLoading.value = true;
    try {
      await _folderService.value?.uploadPhoto(folderId, photo, metadata);
      // 업로드 후 사진 목록 새로고침
      await loadPhotos(folderId);
    } catch (e) {
      print('Error uploading photo: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 사진 삭제
  Future<void> deletePhoto(int? folderId, int photoId) async {
    _isLoading.value = true;
    try {
      await _folderService.value?.deletePhoto(folderId, photoId);
      _photos.removeWhere((photo) => photo.photoId == photoId);
    } catch (e) {
      print('Error deleting photo: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> inviteUserToFolder(int receiverId, int? folderId) async {
    _isLoading.value = true;
    try {
      if (folderId == null) throw ArgumentError('folderId cannot be null');
      await _folderService.value?.inviteToFolder(user.userId, receiverId, folderId);
      print('Successfully sent folder invitation');
    } catch (e) {
      print('Error sending folder invitation: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> respondToFolderInvitation(int noticeId, bool accept) async {
    _isLoading.value = true;
    try {
      await _folderService.value?.acceptInvitation(noticeId, user.userId);
      if (accept) {
        await loadFolders(); // Refresh folders list if accepted
      }
      print('Successfully responded to folder invitation');
    } catch (e) {
      print('Error responding to folder invitation: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  String generateInviteCode(int? folderId) {
    if (folderId == null) return '';
    return (folderId * 7 + 11).toString();
  }

  int? getFolderIdFromCode(String code) {
    try {
      int numericCode = int.parse(code);
      if ((numericCode - 11) % 7 == 0) {
        return (numericCode - 11) ~/ 7;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 코드로 폴더 참여하기
  Future<void> joinFolderWithCode(String code) async {
    _isLoading.value = true;
    try {
      final folderId = getFolderIdFromCode(code);
      if (folderId == null) {
        throw ArgumentError('Invalid invitation code');
      }
      
      // 1. noticeId 얻기
      final noticeId = await _folderService.value?.getNoticeIdForInvitation(user.userId, folderId);
      if (noticeId == null) {
        throw Exception('Could not find invitation notice');
      }

      // 2. 초대 수락하기
      await _folderService.value?.acceptInvitation(noticeId, user.userId);
      
      // 3. 폴더 목록 새로고침
      await loadFolders();
      print('Successfully joined folder with code');
    } catch (e) {
      print('Error joining folder with code: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // UI 상태 관리 메서드
  void togglePhotoListView() {
    _isPhotoList.value = !_isPhotoList.value;
    update();
  }

  void toggleFirst() {
    _isFirst.value = !_isFirst.value;
    update();
  }

  void setCurrentFolder(String? folderName, int folderId) {
    _currentFolderName.value = folderName;  // 이 줄이 빠져있었습니다
    _currentFolderId.value = folderId;
    update();
  }

  void toggleViewMode() {
    _isPhotoMode.value = !_isPhotoMode.value;
  }
  
}