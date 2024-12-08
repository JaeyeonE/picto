import 'package:flutter/material.dart';
import 'dart:io';

import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';
import 'package:picto/services/folder_service.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/photo_store.dart';
import 'package:picto/services/user_manager_service.dart';

class FolderViewModel extends ChangeNotifier {
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

  FolderViewModel({
    required this.user,
    required FolderService folderService,
    required PhotoStoreService photoStoreService,
    required UserManagerService userManagerService,
  }) : _folderService = folderService,
       _photoStoreService = photoStoreService,
       _userManagerService = userManagerService;

  // Getters
  List<FolderModel> get folders => _folders;
  List<Photo> get photos => _photos;
  List<FolderUser> get folderUsers => _folderUsers;
  List<User> get userProfiles => _userProfiles;
  bool get isLoading => _isLoading;
  String? get currentFolderName => _currentFolderName;
  int get currentFolderId => _currentFolderId;
  bool get isPhotoList => _isPhotoList;
  bool get isFirst => _isFirst;
  bool get isPhotoMode => _isPhotoMode;

  // 폴더 목록 로드
  Future<void> loadFolders() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final folders = await _folderService.getFolders(user.userId);
      print('Loaded folders: ${folders?.map((f) => f.toJson())}');
      _folders = folders ?? [];
    } catch (e) {
      print('Error loading folders: $e');
      _folders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 폴더 생성
  Future<void> createFolder(String name, String content) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final newFolder = await _folderService.createFolder(user.userId, name, content);
      if (newFolder != null) {
        _folders.add(newFolder);
        print('created folder: ${newFolder.toJson()}');
      }
    } catch (e) {
      print('Error creating folder: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 폴더 수정
  Future<void> updateFolder(int? folderId, String name, String content) async {
    _isLoading = true;
    notifyListeners();
    
    print('current folder ID: ${folderId}');
    try {
      final updatedFolder = await _folderService.updateFolder(user.userId, folderId, name, content);
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
      _isLoading = false;
      notifyListeners();
    }
  }

  // 폴더 삭제
  Future<void> deleteFolder(int folderId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _folderService.deleteFolder(user.userId, folderId);
      _folders.removeWhere((folder) => folder.folderId == folderId);
    } catch (e) {
      print('Error deleting folder: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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

  // 폴더 사용자 목록 로드
  Future<void> loadFolderUsers(int? folderId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final users = await _folderService.getFolderUsers(user.userId, folderId);
      _folderUsers = users ?? [];
      
      _userProfiles = [];
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
      _folderUsers = [];
      _userProfiles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사진 업로드
  Future<void> uploadPhoto(int folderId, File photo, Map<String, dynamic> metadata) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _folderService.uploadPhoto(folderId, photo, metadata);
      await loadPhotos(folderId);
    } catch (e) {
      print('Error uploading photo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사진 삭제
  Future<void> deletePhoto(int? folderId, int photoId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _folderService.deletePhoto(folderId, photoId);
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

  Future<void> respondToFolderInvitation(int noticeId, bool accept) async {
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

  Future<void> joinFolderWithCode(String code) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final folderId = getFolderIdFromCode(code);
      if (folderId == null) {
        throw ArgumentError('Invalid invitation code');
      }
      
      final noticeId = await _folderService.getNoticeIdForInvitation(user.userId, folderId);
      if (noticeId == null) {
        throw Exception('Could not find invitation notice');
      }

      await _folderService.acceptInvitation(noticeId, user.userId);
      await loadFolders();
      print('Successfully joined folder with code');
    } catch (e) {
      print('Error joining folder with code: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UI 상태 관리 메서드
  void togglePhotoListView() {
    _isPhotoList = !_isPhotoList;
    notifyListeners();
  }

  void toggleFirst() {
    _isFirst = !_isFirst;
    notifyListeners();
  }

  void setCurrentFolder(String? folderName, int folderId) {
    _currentFolderName = folderName;
    _currentFolderId = folderId;
    notifyListeners();
  }

  void toggleViewMode() {
    _isPhotoMode = !_isPhotoMode;
    notifyListeners();
  }
}