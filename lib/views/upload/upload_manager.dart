import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';

class UploadController {
  final ImagePicker _picker = ImagePicker();
  List<AssetEntity> _images = [];
  bool _isLoading = true;
  File? _image;

  List<AssetEntity> get images => _images;
  bool get isLoading => _isLoading;
  File? get image => _image;

  Future<void> loadPhotos() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isNotEmpty) {
        final recentAlbum = albums.first;
        final recentPhotos =
            await recentAlbum.getAssetListRange(start: 0, end: 50);
        _images = recentPhotos;
        _isLoading = false;
      }
    } else {
      await PhotoManager.openSetting();
    }
  }

  Future<void> selectImage(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      _image = file;
    }
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    }
  }

  Future<bool> checkCameraPermission() async {
    final permission = await PhotoManager.requestPermissionExtend();
    return permission.isAuth;
  }
}

class UserDataService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw '위치 서비스가 비활성화되어 있습니다.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw '위치 권한이 거부되었습니다.';
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<String> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality ?? ''} ${place.subLocality ?? ''}'.trim();
      }
      return '';
    } catch (e) {
      print('위치 주소 변환 실패: $e');
      return '';
    }
  }
}
