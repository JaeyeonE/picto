import 'package:flutter/material.dart';

import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/services/folder_service.dart';

class FolderViewModel extends ChangeNotifier {
  final FolderService _folderService;
  FolderModel _folderModel = FolderModel(folderList: []);
  bool _isLoading = false;

  FolderViewModel(this._folderService);

  FolderModel get folderModel => _folderModel;
  bool get isLoading => _isLoading;

  Future<void> loadFolders() async {
    _isLoading = true;
    notifyListeners(); // ??????????
    try {
      final folderList = await _folderService.getFoldersTest();
      _folderModel = FolderModel(folderList: folderList);
    } catch (e) {
      print('Error loading folders $e');
      _folderModel = FolderModel(folderList: []);
    }finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPhotos(String folder) async{
    _isLoading = true;
    
  }
}