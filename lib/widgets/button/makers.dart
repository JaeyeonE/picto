// lib/widgets/map/markers.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/models/user_manager/user.dart';

class MapMarkers {
  static const double MARKER_SIZE = 64.0;
  static const double IMAGE_PADDING = 3.0;
  
  static ui.Image? _myPictoMarker;
  static ui.Image? _yourPictoMarker;

  static Future<void> initializeMarkerImages() async {
    try {
      final ByteData myPictoData = await rootBundle.load('lib/assets/map/my_picto.png');
      final ByteData yourPictoData = await rootBundle.load('lib/assets/map/your_picto.png');
      
      _myPictoMarker = await decodeImageFromList(myPictoData.buffer.asUint8List());
      _yourPictoMarker = await decodeImageFromList(yourPictoData.buffer.asUint8List());
      debugPrint('마커 이미지 로드 완료');
    } catch (e) {
      debugPrint('마커 이미지 로드 실패: $e');
      rethrow;
    }
  }

  static Future<BitmapDescriptor> _createCustomMarker({
    required bool isMyPhoto,
    required String imageUrl,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = Size(MARKER_SIZE, MARKER_SIZE);
    
    // 배경 마커 그리기
    final backgroundImage = isMyPhoto ? _myPictoMarker : _yourPictoMarker;
    if (backgroundImage != null) {
      canvas.drawImageRect(
        backgroundImage,
        Rect.fromLTWH(0, 0, backgroundImage.width.toDouble(), backgroundImage.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
    }

    try {
      // 이미지 URL 유효성 검사
      if (imageUrl.isEmpty) {
        throw Exception('Invalid image URL');
      }

      // 이미지 URL로부터 이미지 로드
      final imageProvider = NetworkImage(imageUrl);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<ui.Image>();
      
      imageStream.addListener(ImageStreamListener((info, _) {
        completer.complete(info.image);
      }, onError: (exception, stackTrace) {
        completer.completeError(exception);
      }));

      final image = await completer.future;
      
      // 이미지를 패딩을 적용하여 그리기
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(
          IMAGE_PADDING,
          IMAGE_PADDING,
          size.width - (IMAGE_PADDING * 2),
          size.height - (IMAGE_PADDING * 2),
        ),
        Paint(),
      );

      final picture = pictureRecorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (data == null) {
        throw Exception('Failed to convert image to bytes');
      }

      return BitmapDescriptor.bytes(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('마커 이미지 생성 실패: $e');
      // 에러 발생 시 기본 마커 반환
      return isMyPhoto 
        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  static Future<Marker?> createPhotoMarker({
    required Photo photo,
    required User currentUser,
    required Function(Photo) onTap,
  }) async {
    if (photo.lat == null || photo.lng == null) return null;
    
    final isMyPhoto = photo.userId == currentUser.userId.toString();
    final imageUrl = isMyPhoto 
      ? (currentUser.profilePhotoPath ?? '')
      : (photo.photoPath);
    
    try {
      final customMarker = await _createCustomMarker(
        isMyPhoto: isMyPhoto,
        imageUrl: imageUrl,
      );

      return Marker(
        markerId: MarkerId("${isMyPhoto ? 'my' : 'other'}_photo_${photo.photoId}"),
        position: LatLng(photo.lat!, photo.lng!),
        icon: customMarker,
        onTap: () => onTap(photo),
        infoWindow: InfoWindow(
          title: photo.location ?? '위치 정보 없음',
          snippet: """${isMyPhoto ? '내 사진 • ' : ''}좋아요: ${photo.likes} • 조회수: ${photo.views}${photo.tag != null ? ' • #${photo.tag}' : ''}""",
        ),
      );
    } catch (e) {
      debugPrint('마커 생성 오류: $e');
      return null;
    }
  }

  static Marker createMyLocationMarker(LatLng location) {
    return Marker(
      markerId: const MarkerId("myLocation"),
      position: location,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: "내 위치"),
    );
  }
}