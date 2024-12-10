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
  static const String FALLBACK_IMAGE = 'lib/assets/map/dog.png';

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

      if (decodedPhoto == null) throw Exception('Failed to decode photo');

      final paddedSize = PHOTO_SIZE + (PADDING * 2);
      final resizedPhoto = img.copyResize(
        decodedPhoto,
        width: PHOTO_SIZE.toInt(),
        height: PHOTO_SIZE.toInt(),
      );
      
      final composite = img.Image(
        width: paddedSize.toInt(),
        height: paddedSize.toInt(),
        format: img.Format.uint8,
      );
      
      final mask = img.Image(
        width: paddedSize.toInt(),
        height: paddedSize.toInt()
      );
      img.fillCircle(
        mask,
        x: paddedSize.toInt() ~/ 2,
        y: paddedSize.toInt() ~/ 2,
        radius: (paddedSize / 2).toInt(),
        color: img.ColorRgba8(255, 255, 255, 255)
      );

      final paddingColor = isCurrentUser 
          ? img.ColorRgba8(112, 56, 255, 255)
          : img.ColorRgba8(255, 255, 255, 255);
      
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

      final bytes = img.encodePng(composite);
      return BitmapDescriptor.fromBytes(bytes);
    } catch (e) {
      print("마커 이미지 생성 실패: $e");
      throw Exception('Failed to create marker icon: $e');
    }
  }
}