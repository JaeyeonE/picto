import 'package:flutter/material.dart';

import 'package:picto/models/common/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/services/folder_service.dart';

class FolderViewModel extends ChangeNotifier {
  final FolderService _folderService;
  FolderModel _folderModel = FolderModel(folderList: []);
  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _currentFolderName = null;
  bool _isPhotoList = false;
  bool _isFirst = true; // 헤더스위치

  FolderViewModel(this._folderService);

  FolderModel get folderModel => _folderModel;
  List<Photo> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get currentFolderName => _currentFolderName;
  bool get isPhotoList => _isPhotoList;
  bool get isFirst => _isFirst;

  Future<void> loadFolders() async {
    _isLoading = true;
    notifyListeners(); // ??????????
    try {
      final folderList = await _folderService.getFoldersTest();
      _folderModel = FolderModel(folderList: folderList);
    } catch (e) {
      print('Error loading folders $e');
      _folderModel = FolderModel(folderList: []);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPhotos(String folderName) async {
    _isLoading = true;
    notifyListeners();

    try {
      _photos = await _folderService.getPhotosTest(folderName);
    } catch (e) {
      print('error loading photos: $e');
      _photos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleMode(){
    _isFirst = !_isFirst;
    notifyListeners;
  }

  void getFolderName(String folderName){
    _currentFolderName = folderName;
    notifyListeners();
  }
}