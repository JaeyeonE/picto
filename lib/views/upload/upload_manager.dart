import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> checkAndRequestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}

class UploadController {
  final ImagePicker _picker = ImagePicker();
  List<AssetEntity> _images = [];
  bool _isLoading = true;
  File? _image;

  List<AssetEntity> get images => _images;
  bool get isLoading => _isLoading;
  File? get image => _image;

  Future<void> loadPhotos() async {
    final hasPermission = await PermissionService.checkAndRequestPermission(
      Permission.photos,
    );

    if (!hasPermission) {
      throw '사진 접근 권한이 거부되었습니다.';
    }

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (albums.isNotEmpty) {
      final recentAlbum = albums.first;
      final recentPhotos = await recentAlbum.getAssetListRange(
        start: 0,
        end: 50,
      );
      _images = recentPhotos;
      _isLoading = false;
    }
  }

  Future<void> selectImage(AssetEntity asset) async {
    final hasPermission = await PermissionService.checkAndRequestPermission(
      Permission.photos,
    );

    if (!hasPermission) {
      throw '사진 접근 권한이 거부되었습니다.';
    }

    final file = await asset.file;
    if (file != null) {
      _image = file;
    }
  }

  Future<void> getImage(ImageSource source) async {
    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    final hasPermission = await PermissionService.checkAndRequestPermission(
      permission,
    );

    if (!hasPermission) {
      throw '${source == ImageSource.camera ? '카메라' : '사진'} 접근 권한이 거부되었습니다.';
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    }
  }
}

class UserDataService {
  static Future<Position> getCurrentLocation() async {
    final hasPermission = await PermissionService.checkAndRequestPermission(
      Permission.location,
    );

    if (!hasPermission) {
      throw '위치 접근 권한이 거부되었습니다.';
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw '위치 서비스가 비활성화되어 있습니다.';
    }

    return await Geolocator.getCurrentPosition();
  }
}
