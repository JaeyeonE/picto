import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/utils/app_color.dart';
import 'package:http/http.dart' as http;

class MarkerImageProcessor {
  static const double MARKER_SIZE = 110.0;
  static const double PHOTO_SIZE = 80.0;
  static const double PADDING = 10.0;
  static const double CORNER_RADIUS = 15.0;
  static const String FALLBACK_IMAGE = 'lib/assets/map/search.png';

  // 마커 색상 정의
  static final Color currentUserColor = const Color.fromRGBO(112, 56, 255, 1);
  static final Color otherUserColor = const Color.fromRGBO(255, 255, 255, 255);

  /// 마커 아이콘 생성을 위한 메인 함수
  /// [isCurrentUser] - 현재 사용자의 마커인지 여부
  /// [photo] - 마커에 표시할 사진 데이터 (선택적)
  static Future<BitmapDescriptor> createMarkerIcon(
    bool isCurrentUser, 
    Photo photo
  ) async {
    try {
      late final Uint8List photoBytes;
      late final img.Image? decodedPhoto;

      if (photo.photoPath.trim().isNotEmpty) {
        try {
          print("=======marker_image_processor.dart S3 이미지 로드 시도 =========");
          print("S3 photoPath: ${photo.photoPath}");
          
          // http 패키지를 사용하여 S3 이미지 다운로드
          final response = await http.get(Uri.parse(photo.photoPath));
          
          if (response.statusCode != 200) {
            throw Exception('S3 이미지 다운로드 실패: ${response.statusCode}');
          }
          
          photoBytes = response.bodyBytes;
          decodedPhoto = img.decodeImage(photoBytes);
          
          if (decodedPhoto == null) {
            throw Exception('S3 이미지 디코딩 실패');
          }
          
          print("S3 이미지 로드 성공!");
        } catch (e) {
          print("S3 이미지 로드 실패: $e");
          // S3 이미지 로드 실패시 폴백 이미지 사용
          final defaultBytes = await rootBundle.load(FALLBACK_IMAGE);
          photoBytes = defaultBytes.buffer.asUint8List();
          decodedPhoto = img.decodeImage(photoBytes);
        }
      } else {
        // photoPath가 비어있을 경우 폴백 이미지 사용
        final defaultBytes = await rootBundle.load(FALLBACK_IMAGE);
        photoBytes = defaultBytes.buffer.asUint8List();
        decodedPhoto = img.decodeImage(photoBytes);
      }

      // 2. 마커 이미지 생성
      final img.Image markerImage = await _createMarkerImage(
        sourceImage,
        isCurrentUser: isCurrentUser,
      );

      final paddingColor = isCurrentUser 
          ? img.ColorRgba8(112, 56, 255, 255) // 보라
          : img.ColorRgba8(255, 255, 255, 255); // 하양
      
      img.fill(composite, color: paddingColor);

      for (var y = 0; y < paddedSize.toInt(); y++) {
        for (var x = 0; x < paddedSize.toInt(); x++) {
          final maskColor = mask.getPixel(x, y);
          if (maskColor == 0) {
            composite.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
          }
        }
      }
      
      img.compositeImage(
        composite,
        resizedPhoto,
        dstX: PADDING.toInt(),
        dstY: PADDING.toInt()
      );

  /// 소스 이미지 준비
  static Future<img.Image> _prepareSourceImage(Photo? photo) async {
    try {
      if (photo?.imageData != null) {
        final decodedImage = img.decodeImage(photo!.imageData!);
        if (decodedImage != null) return decodedImage;
      }
      throw Exception('이미지 디코딩 실패');
    } catch (e) {
      print("기본 이미지로 대체: $e");
      // 폴백 이미지 로드
      final defaultBytes = await rootBundle.load(FALLBACK_IMAGE);
      final decodedDefault = img.decodeImage(defaultBytes.buffer.asUint8List());
      if (decodedDefault == null) throw Exception('기본 이미지 로드 실패');
      return decodedDefault;
    }
  }

  /// 마커 이미지 생성
  static img.Image _createMarkerImage(
      img.Image sourceImage,
      {required bool isCurrentUser}
      ) {
    // 이미지 크기 계산
    final paddedSize = (PHOTO_SIZE + (PADDING * 2)).toInt();

    // 원본 이미지 리사이징
    final resizedImage = img.copyResize(
      sourceImage,
      width: PHOTO_SIZE.toInt(),
      height: PHOTO_SIZE.toInt(),
    );

    // 최종 이미지 생성
    final composite = img.Image(
      width: paddedSize,
      height: paddedSize,
      format: img.Format.uint8,
    );

    // 원형 마스크 생성 및 적용
    _applyCircularMask(composite, paddedSize);

    // 테두리 색상 설정 및 적용
    _applyBorder(
      composite,
      isCurrentUser ? currentUserColor : otherUserColor,
    );

    // 이미지 합성
    img.compositeImage(
      composite,
      resizedImage,
      dstX: PADDING.toInt(),
      dstY: PADDING.toInt(),
    );

    return composite;
  }

  /// 원형 마스크 적용
  static void _applyCircularMask(img.Image image, int size) {
    final mask = img.Image(width: size, height: size);

    // 원형 마스크 그리기
    img.fillCircle(
      mask,
      x: size ~/ 2,
      y: size ~/ 2,
      radius: (size / 2).toInt(),
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    // 마스크 적용
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        if (mask.getPixel(x, y) == 0) {
          image.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        }
      }
    }
  }
}