import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:picto/models/common/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';
import 'package:picto/services/folder_service.dart';

class FolderViewModel extends GetxController {
  final Rxn<FolderService> _folderService;
  final RxList<FolderModel> _folders = RxList([]);
  final RxList<Photo> _photos = RxList([]);
  final RxList<FolderUser> _folderUsers = RxList([]);
  final RxBool _isLoading = false.obs;
  final RxnString _currentFolderName = RxnString();
  final RxnInt _currentFolderId = RxnInt();
  final RxBool _isPhotoList = true.obs;
  final RxBool _isFirst = true.obs;
  final RxBool _isPhotoMode = true.obs;

  FolderViewModel(FolderService folderService)
      : _folderService = Rxn(folderService);

  // Getters
  List<FolderModel> get folders => _folders;
  List<Photo> get photos => _photos;
  List<FolderUser> get folderUsers => _folderUsers;
  bool get isLoading => _isLoading.value;
  String? get currentFolderName => _currentFolderName.value;
  int? get currentFolderId => _currentFolderId.value;
  bool get isPhotoList => _isPhotoList.value;
  bool get isFirst => _isFirst.value;
  bool get isPhotoMode => _isPhotoMode.value;

  // 폴더 목록 로드
  Future<void> loadFolders() async {
    _isLoading.value = true;
    try {
      final folders = await _folderService.value?.getFolders();
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
      final newFolder = await _folderService.value?.createFolder(name, content);
      if (newFolder != null) {
        _folders.add(newFolder);
      }
    } catch (e) {
      print('Error creating folder: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 폴더 수정
  Future<void> updateFolder(int folderId, String name, String content) async {
    _isLoading.value = true;
    try {
      final updatedFolder = await _folderService.value?.updateFolder(folderId, name, content);
      if (updatedFolder != null) {
        final index = _folders.indexWhere((folder) => folder.folderId == folderId);
        if (index != -1) {
          _folders[index] = updatedFolder;
        }
      }
    } catch (e) {
      print('Error updating folder: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 폴더 삭제
  Future<void> deleteFolder(int? folderId) async {
    _isLoading.value = true;
    try {
      await _folderService.value?.deleteFolder(folderId);
      _folders.removeWhere((folder) => folder.folderId == folderId);
    } catch (e) {
      print('Error deleting folder: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 폴더 내 사진 목록 로드
  Future<void> loadPhotos(int? folderId) async {
    _isLoading.value = true;
    try {
      final photos = await _folderService.value?.getPhotosTest(folderId);
      _photos.assignAll(photos ?? []);
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
      final users = await _folderService.value?.getFolderUsers(folderId);
      _folderUsers.assignAll(users ?? []);
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

  void setCurrentFolder(String folderName, int? folderId) {
    _currentFolderName.value = folderName;
    _currentFolderId.value = folderId;
    update();
  }

  void toggleViewMode() {
    _isPhotoMode.value = !_isPhotoMode.value;
  }
  
}