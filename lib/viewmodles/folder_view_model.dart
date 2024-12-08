import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';
import 'package:picto/models/user_manager/auth_responses.dart';
import 'package:picto/services/folder_service.dart';
import 'package:picto/models/user_manager/user.dart';

class FolderViewModel extends GetxController {
  final User user;
  final FolderService _folderService;
  final PhotoStoreService _photoStoreService;
  final UserManagerService _userManagerService;
  
  List<FolderModel> _folders = [];
  List<Photo> _photos = [];
  List<FolderUser> _folderUsers = [];
  List<User> _userProfiles = [];
  bool _isLoading = false;
  String? _currentFolderName;
  int _currentFolderId = 0;
  bool _isPhotoList = true;
  bool _isFirst = true;
  bool _isPhotoMode = true;
  UserInfoResponse? _userInfo;

  FolderViewModel({
    required this.user,
  required FolderService folderService,})
      : _folderService = Rxn(folderService);

  // Getters
  List<FolderModel> get folders => _folders;
  UserManagerService get userManagerService => _userManagerService;
  List<Photo> get photos => _photos;
  List<FolderUser> get folderUsers => _folderUsers;
  List<User> get userProfiles => _userProfiles;
  bool get isLoading => _isLoading;
  String? get currentFolderName => _currentFolderName;
  int get currentFolderId => _currentFolderId;
  bool get isPhotoList => _isPhotoList;
  bool get isFirst => _isFirst;
  bool get isPhotoMode => _isPhotoMode;
  UserInfoResponse? get userInfo => _userInfo;
  

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
    _isLoading = true;
    notifyListeners();
    
    try {
      final photos = await _folderService.getPhotos(user.userId, folderId);
      if (photos != null) {
        for (var photo in photos) {
          try {
            final response = await _photoStoreService.downloadPhoto(photo.photoId.toString());
            if (response.statusCode == 200) {
              photo.photoPath = response.body;
            }
          } catch (e) {
            print('Error downloading photo ${photo.photoId}: $e');
          }
        }
        _photos = photos;
      } else {
        _photos = [];
      }
      _currentFolderId = folderId;
    } catch (e) {
      print('Error loading photos: $e');
      _photos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //유저가 업로드한 사진 가져오기
  Future<void> loadUserPhotos(int userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userInfo = await _userManagerService.getUserAllInfo(userId);
      _userInfo = userInfo;
      
      // 사진 경로 로드
      final List<Photo> photos = [];
      for (var photo in userInfo.photos) {
        try {
          final response = await _photoStoreService.downloadPhoto(photo.photoId.toString());
          if (response.statusCode == 200) {
            photo.photoPath = response.body;
            photos.add(photo);
          }
        } catch (e) {
          print('Error downloading photo ${photo.photoId}: $e');
        }
      }
      _photos = photos;
    } catch (e) {
      print('Error loading user photos: $e');
      _photos = [];
      _userInfo = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 이메일 검색

  // 폴더 사용자 목록 로색
  Future<void> loadFolderUsers(int? folderId) async {
    _isLoading.value = true;
    try {
      final users = await _folderService.value?.getFolderUsers(user.userId, folderId);
      _folderUsers.assignAll(users ?? []);
      print('Loaded folder users: ${users?.map((f) => f.toJson())}');
    } catch (e) {
      print('Error loading folder users: $e');
      _folderUsers.clear();
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
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> inviteUserToFolder(int receiverId, int? folderId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (folderId == null) throw ArgumentError('folderId cannot be null');
      await _folderService.inviteToFolder(user.userId, receiverId, folderId);
      print('Successfully sent folder invitation');
    } catch (e) {
      print('Error sending folder invitation: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptInvitation(int noticeId, bool accept) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _folderService.acceptInvitation(noticeId, user.userId);
      if (accept) {
        await loadFolders();
      }
      print('Successfully responded to folder invitation');
    } catch (e) {
      print('Error responding to folder invitation: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> loadInvitation(int userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
    
      final noticeId = await _folderService.getNoticeIdForInvitation(userId, folderId);
      if (noticeId == null) {
        throw Exception('Could not find invitation notice');
      }

      await _folderService.acceptInvitation(noticeId, user.userId);
      print('Successfully joined folder');
    } catch (e) {
      print('Error joining folder: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _currentFolderId.value = folderId;
    update();
  }

  void toggleViewMode() {
    _isPhotoMode.value = !_isPhotoMode.value;
  }
  
}