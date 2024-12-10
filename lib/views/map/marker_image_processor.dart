// import 'dart:ui' as ui;
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:picto/utils/app_color.dart';

// class MarkerImageProcessor {
//   static const double MARKER_SIZE = 110.0;
//   static const double PHOTO_SIZE = 80.0;
//   static const double PADDING = 10.0;
//   static const double CORNER_RADIUS = 15.0;
//   static const String FALLBACK_IMAGE = 'lib/assets/map/dog.png';

//   static Future<BitmapDescriptor> createMarkerIcon(bool isCurrentUser) async {
//     try {
//       final photoBytes = await rootBundle.load(FALLBACK_IMAGE);
//       final photo = img.decodeImage(photoBytes.buffer.asUint8List());
//       if (photo == null) throw Exception('Failed to load photo');

//       // 커스텀 사진으로 마커 생성


//       final paddedSize = PHOTO_SIZE + (PADDING * 2);
//       final resizedPhoto = img.copyResize(photo, width: PHOTO_SIZE.toInt(), height: PHOTO_SIZE.toInt());
      
//       final composite = img.Image(
//         width: paddedSize.toInt(),
//         height: paddedSize.toInt(),
//         format: img.Format.uint8,
//       );
      
      
//       // Create a mask for rounded corners
//       final mask = img.Image(width: paddedSize.toInt(), height: paddedSize.toInt());
//       img.fillCircle(
//         mask,
//         x: paddedSize.toInt() ~/ 2,
//         y: paddedSize.toInt() ~/ 2,
//         radius: (paddedSize / 2).toInt(),
//         color: img.ColorRgba8(255, 255, 255, 255)
//       );

//       final paddingColor = isCurrentUser 
//           ? img.ColorRgba8(112, 56, 255, 255)
//           : img.ColorRgba8(255, 255, 255, 255);
      
//       img.fill(composite, color: paddingColor);

//       // Apply mask for rounded corners
//       for (var y = 0; y < paddedSize.toInt(); y++) {
//         for (var x = 0; x < paddedSize.toInt(); x++) {
//           final maskColor = mask.getPixel(x, y);
//           if (maskColor == 0) {
//             composite.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
//           }
//         }
//       }
      
//       img.compositeImage(composite, resizedPhoto, 
//           dstX: PADDING.toInt(), 
//           dstY: PADDING.toInt());

//       final bytes = img.encodePng(composite);
//       return BitmapDescriptor.fromBytes(bytes);
//     } catch (e) {
//       throw Exception('Failed to create marker icon: $e');
//     }
//   }
// }

import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/utils/app_color.dart';
import 'package:dio/dio.dart';

class MarkerImageProcessor {
  static const double MARKER_SIZE = 110.0;
  static const double PHOTO_SIZE = 80.0;
  static const double PADDING = 10.0;
  static const double CORNER_RADIUS = 15.0;
  static const String FALLBACK_IMAGE = 'lib/assets/map/dog.png';

  static Future<BitmapDescriptor> createMarkerIcon(
    bool isCurrentUser, 
    {Photo? photo}
  ) async {
    try {
      late final Uint8List photoBytes;
      late final img.Image? decodedPhoto;

      if (photo != null && photo.photoPath.trim().isNotEmpty) {
        try {
          print("=======marker_image_processor.dart 에서 호출 =========");
          print("photoPath: ${photo.photoPath}");
          
          // 직접 Dio 인스턴스를 생성하여 이미지 다운로드
          final response = await Dio().get(
            photo.photoPath,
            options: Options(
              responseType: ResponseType.bytes,
            ),
          );
          
          photoBytes = Uint8List.fromList(response.data);
          decodedPhoto = img.decodeImage(photoBytes);
          
          if (decodedPhoto == null) {
            throw Exception('이미지 디코딩 실패');
          }
          
          print("이미지 로드 성공!");
        } catch (e) {
          print("이미지 로드 실패: $e");
          // photoPath 로드 실패시 폴백 이미지 사용
          final defaultBytes = await rootBundle.load(FALLBACK_IMAGE);
          photoBytes = defaultBytes.buffer.asUint8List();
          decodedPhoto = img.decodeImage(photoBytes);
        }
      } else {
        // photo가 null이거나 photoPath가 비어있을 경우 폴백 이미지 사용
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
