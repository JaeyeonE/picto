
import 'package:flutter/material.dart';
import 'package:picto/models/folder/invite_model.dart';

import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'package:picto/models/folder/folder_user.dart';
import 'package:picto/models/user_manager/auth_responses.dart';
import 'package:picto/services/folder_service.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/photo_store.dart';
import 'package:picto/services/user_manager_service.dart';

class FolderViewModel extends ChangeNotifier {
  late final User user;
  final FolderService _folderService;
  final PhotoStoreService _photoStoreService;
  final UserManagerService _userManagerService;
  
  List<FolderModel> _folders = [];
  List<Photo> _photos = [];
  List<FolderUser> _folderUsers = [];
  List<User> _userProfiles = [];
  bool _isLoading = false;
  String? _currentFolderName;
  static const int INVALID_FOLDER_ID = -1;
  int _currentFolderId = INVALID_FOLDER_ID;
  bool _isPhotoList = true;
  bool _isFirst = true;
  bool _isPhotoMode = true;
  UserInfoResponse? _userInfo;
  List<Invite> _invitations = [];

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
  List<Invite> get invitations => _invitations;

  

  // 폴더 목록 로드
  Future<void> loadFolders() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final folders = await _folderService.getFolders(user.userId);
      print('Loaded folders: ${folders.map((f) => f.toJson())}');
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
      _folders.add(newFolder);
      print('created folder: ${newFolder.toJson()}');
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
      final index = _folders.indexWhere((folder) => folder.folderId == folderId);
      if (index != -1) {
        _folders[index] = updatedFolder;
      }
      print('updated folder: ${updatedFolder.toJson()}');
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

  // 특정 폴더 목록 안에 사진 데이터 로딩
  Future<void> loadPhotos(int folderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 폴더에 있는 사진 정보를 가져옵니다
      final photos = await _folderService.getPhotos(user.userId, folderId);

      // 모든 사진의 이미지 데이터를 병렬로 로드합니다
      await Future.wait(
          photos.map((photo) => _loadPhotoImage(photo))
      );

      // 상태 업데이트
      _photos = photos;
      _currentFolderId = folderId;

    } catch (e) {
      print('폴더 사진 목록 로드 실패: $e');
      _photos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 개별 사진의 이미지 데이터를 로드하는 메서드
  Future<void> _loadPhotoImage(Photo photo) async {
    try {
      photo.isLoading = true;

      // 이전에 개선한 PhotoService의 downloadPhoto를 사용합니다
      // 이 메소드는 이미 PhotoResponse 형태로 이미지 데이터와 컨텐츠 타입을 반환합니다
      final response = await _photoStoreService.downloadPhoto(photo.photoId);

      // PhotoResponse의 데이터를 Photo 객체에 설정
      photo.imageData = response.imageData;  // 이미 Uint8List 타입으로 변환되어 있음
      photo.contentType = response.contentType;
      photo.errorMessage = null;

    } catch (e) {
      print('사진 ${photo.photoId} 다운로드 실패: $e');
      photo.errorMessage = '이미지를 불러올 수 없습니다';
      photo.imageData = null;
    } finally {
      photo.isLoading = false;
    }
  }


  // 유저의 모든 사진 로드
  Future<void> loadUserPhotos(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 사용자 정보와 사진 목록을 가져옵니다
      final userInfo = await _userManagerService.getUserAllInfo(userId);
      _userInfo = userInfo;

      if (userInfo.photos.isEmpty) {
        _photos = [];
        return;
      }

      // 모든 사진의 이미지 데이터를 병렬로 로드합니다
      await Future.wait(
          userInfo.photos.map((photo) => _loadPhotoImage(photo))
      );

      // 성공적으로 로드된 사진만 필터링하여 저장
      _photos = userInfo.photos.where((photo) => photo.imageData != null).toList();

    } catch (e) {
      print('사용자 사진 로드 실패: $e');
      _photos = [];
      _userInfo = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 이메일 검색
  Future<User?> searchUserByEmail(String email) async {
  try {
    final user = await _userManagerService.getUserProfileByEmail(email);
    return user;
  } catch (e) {
    print('Error searching user by email: $e');
    return null;
  }
}


  // 폴더 사용자 목록 로색
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

  // // 사진 업로드
  // Future<void> uploadPhoto(int folderId, File photo, Map<String, dynamic> metadata) async {
  //   _isLoading = true;
  //   notifyListeners();
    
  //   try {
  //     await _folderService.uploadPhoto(folderId, photo, metadata);
  //     await loadPhotos(folderId);
  //   } catch (e) {
  //     print('Error uploading photo: $e');
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

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

  Future<void> acceptInvitation(int noticeId, bool accept) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _folderService.acceptInvitation(noticeId, user.userId, accept);
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
      final invites = await _folderService.getInvitations(user.userId);
      _invitations = invites;
      print('Loaded ${invites.length} invitations');
    } catch (e) {
      print('Error loading invitations: $e');
      _invitations = [];
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
    // 폴더 리스트로 돌아갈 때의 케이스를 명확히 처리
    if (folderName == null || folderName.isEmpty) {
      _currentFolderName = null;
      _currentFolderId = INVALID_FOLDER_ID; // 또는 null
    } else {
      _currentFolderName = folderName;
      _currentFolderId = folderId;
    }
    notifyListeners();
  }

  void toggleViewMode() {
    _isPhotoMode = !_isPhotoMode;
    notifyListeners();
  }

  bool get isInFolder => 
    _currentFolderName != null && 
    _currentFolderName!.isNotEmpty && 
    _currentFolderId != INVALID_FOLDER_ID;

}