import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;

class MarkerImageProcessor {
  static const double MARKER_SIZE = 80.0;
  static const double PHOTO_SIZE = 76.0;
  static const String FALLBACK_IMAGE = 'lib/assets/map/dog.png';

  static img.Image? _myPictoFrame;
  static img.Image? _yourPictoFrame;

  // 프레임 이미지 로드 및 캐싱
  static Future<void> loadFrameImages() async {
    if (_myPictoFrame == null || _yourPictoFrame == null) {
      final myPictoBytes = await rootBundle.load('lib/assets/map/my_picto.png');
      final yourPictoBytes =
          await rootBundle.load('lib/assets/map/your_picto.png');

      _myPictoFrame = img.decodePng(myPictoBytes.buffer.asUint8List());
      _yourPictoFrame = img.decodePng(yourPictoBytes.buffer.asUint8List());
    }
  }

  // 사진 경로 검증 및 수정
  static String _validatePhotoPath(String photoPath) {
    if (photoPath.startsWith('s3://') || photoPath.startsWith('temp_path')) {
      return FALLBACK_IMAGE;
    }
    return photoPath;
  }

  // 마커 이미지 생성
  static Future<BitmapDescriptor> createMarkerIcon(
      String photoPath, bool isCurrentUser) async {
    await loadFrameImages(); // 프레임 이미지 로드

    // 사진 경로 검증
    final validatedPhotoPath = _validatePhotoPath(photoPath);

    try {
      // 프레임 선택 및 크기 조정 (80x80)
      final frame = isCurrentUser ? _myPictoFrame! : _yourPictoFrame!;
      final frameResized = img.copyResize(frame,
          width: MARKER_SIZE.toInt(), height: MARKER_SIZE.toInt());

      // 사진 로드
      final photoBytes = await rootBundle.load(validatedPhotoPath);
      final photo = img.decodeImage(photoBytes.buffer.asUint8List());
      if (photo == null) throw Exception('Failed to load photo');

      // 사진 크기를 프레임의 9/10로 조정
      final photoSize = (MARKER_SIZE * 0.9).toInt(); // 72x72
      final resizedPhoto =
          img.copyResize(photo, width: photoSize, height: photoSize);

      // 둥근 모서리 마스크 생성
      final mask = img.Image(width: photoSize, height: photoSize);
      img.fillCircle(mask,
          x: photoSize ~/ 2,
          y: photoSize ~/ 2,
          radius: 20,
          color: img.ColorRgba8(255, 255, 255, 255));

      // 마스크 적용
      for (var y = 0; y < photoSize; y++) {
        for (var x = 0; x < photoSize; x++) {
          final maskColor = mask.getPixel(x, y);
          if (maskColor == 0) {
            resizedPhoto.setPixel(x, y, 0 as img.Color); // 투명하게 설정
          }
        }
      }

      // 최종 이미지 생성
      final composite =
          img.Image(width: MARKER_SIZE.toInt(), height: MARKER_SIZE.toInt());

      // 사진을 중앙에 배치
      final x = (MARKER_SIZE.toInt() - photoSize) ~/ 2;
      final y = (MARKER_SIZE.toInt() - photoSize) ~/ 2;
      img.compositeImage(composite, resizedPhoto, dstX: x, dstY: y);

      // 프레임 합성
      img.compositeImage(composite, frameResized);

      // BitmapDescriptor로 변환
      final bytes = img.encodePng(composite);

      // BitmapDescriptor 생성 (deprecated 방식이지만 현재 대체 방법이 없음)
      return BitmapDescriptor.fromBytes(bytes);
    } catch (e) {
      // 이미지 로드 실패시에도 fallback 이미지 사용
      return await createMarkerIcon(FALLBACK_IMAGE, isCurrentUser);
    }
  }
}
