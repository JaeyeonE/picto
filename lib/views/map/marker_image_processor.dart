import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;

class MarkerImageProcessor {
 static const double MARKER_SIZE = 110.0;
 static const double PHOTO_SIZE = 80.0;
 static const String FALLBACK_IMAGE = 'lib/assets/map/dog.png';
 
 static img.Image? _myPictoFrame;
 static img.Image? _yourPictoFrame;

 // 프레임 이미지 로드 및 캐싱
 static Future<void> loadFrameImages() async {
   if (_myPictoFrame == null || _yourPictoFrame == null) {
     final myPictoBytes = await rootBundle.load('lib/assets/map/my_picto.png');
     final yourPictoBytes = await rootBundle.load('lib/assets/map/your_picto.png');
     
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
  // 만약 새로 뜬 이미지의 유저 아이디가 내 것과 같다면
 // 마커 이미지 생성
 static Future<BitmapDescriptor> createMarkerIcon(int userId, String photoPath, bool isCurrentUser) async {
   await loadFrameImages();

   final validatedPhotoPath = _validatePhotoPath(photoPath);

   try {
     // 프레임 선택 및 크기 조정
     final frame = isCurrentUser ? _myPictoFrame! : _yourPictoFrame!;
     final frameResized = img.copyResize(frame, width: MARKER_SIZE.toInt(), height: MARKER_SIZE.toInt());

     // 사진 로드
     final photoBytes = await rootBundle.load(validatedPhotoPath);
     final photo = img.decodeImage(photoBytes.buffer.asUint8List());
     if (photo == null) throw Exception('Failed to load photo');

     // 사진 크기를 PHOTO_SIZE로 조정
     final resizedPhoto = img.copyResize(photo, width: PHOTO_SIZE.toInt(), height: PHOTO_SIZE.toInt());
     
     // 둥근 모서리 마스크 생성
     final mask = img.Image(width: PHOTO_SIZE.toInt(), height: PHOTO_SIZE.toInt());
     img.fillCircle(
       mask,
       x: PHOTO_SIZE.toInt() ~/ 2,
       y: PHOTO_SIZE.toInt() ~/ 2,
       radius: 20,
       color: img.ColorRgba8(255, 255, 255, 255)
     );

     // 마스크 적용
     for (var y = 0; y < PHOTO_SIZE.toInt(); y++) {
       for (var x = 0; x < PHOTO_SIZE.toInt(); x++) {
         final maskColor = mask.getPixel(x, y);
         if (maskColor == 0) {
           resizedPhoto.setPixel(x, y, 0 as img.Color);
         }
       }
     }

     // 투명한 배경으로 최종 이미지 생성
     final composite = img.Image(
       width: MARKER_SIZE.toInt(),
       height: MARKER_SIZE.toInt(),
       format: img.Format.uint8, // 투명도 지원을 위해 RGBA 형식 사용
     );
     
     // 배경을 완전 투명하게 설정
     img.fill(composite, color: img.ColorRgba8(0, 0, 0, 0));
     
     // 프레임을 먼저 배치
     img.compositeImage(composite, frameResized);
     
     // 사진을 중앙에 배치
     final x = (MARKER_SIZE.toInt() - PHOTO_SIZE.toInt()) ~/ 2;
     final y = (MARKER_SIZE.toInt() - PHOTO_SIZE.toInt()) ~/ 2;
     img.compositeImage(composite, resizedPhoto, dstX: x, dstY: y-5);

     final bytes = img.encodePng(composite);
     return BitmapDescriptor.fromBytes(bytes);
   } catch (e) {
     return await createMarkerIcon(userId, FALLBACK_IMAGE, isCurrentUser);
   }
 }
}


// import 'dart:ui' as ui;
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image/image.dart' as img;

// class MarkerImageProcessor {
//   static const double MARKER_SIZE = 120.0;
//   static const double PHOTO_SIZE = 80.0;
//   static const String FALLBACK_IMAGE = 'lib/assets/map/dog.png';

//   static img.Image? _myPictoFrame;
//   static img.Image? _yourPictoFrame;

//   // 프레임 이미지 로드 및 캐싱
//   static Future<void> loadFrameImages() async {
//     if (_myPictoFrame == null || _yourPictoFrame == null) {
//       final myPictoBytes = await rootBundle.load('lib/assets/map/my_picto.png');
//       final yourPictoBytes =
//           await rootBundle.load('lib/assets/map/your_picto.png');

//       _myPictoFrame = img.decodePng(myPictoBytes.buffer.asUint8List());
//       _yourPictoFrame = img.decodePng(yourPictoBytes.buffer.asUint8List());
//     }
//   }

//   // 사진 경로 검증 및 수정
//   static String _validatePhotoPath(String photoPath) {
//     if (photoPath.startsWith('s3://') || photoPath.startsWith('temp_path')) {
//       return FALLBACK_IMAGE;
//     }
//     return photoPath;
//   }

//   // 마커 이미지 생성
//   static Future<BitmapDescriptor> createMarkerIcon(
//       String photoPath, bool isCurrentUser) async {
//     await loadFrameImages(); // 프레임 이미지 로드

//     // 사진 경로 검증
//     final validatedPhotoPath = _validatePhotoPath(photoPath);

//     try {
//       // 프레임 선택 및 크기 조정 (80x80)
//       final frame = isCurrentUser ? _myPictoFrame! : _yourPictoFrame!;
//       final frameResized = img.copyResize(frame,
//           width: MARKER_SIZE.toInt(), height: MARKER_SIZE.toInt());

//       // 사진 로드
//       final photoBytes = await rootBundle.load(validatedPhotoPath);
//       final photo = img.decodeImage(photoBytes.buffer.asUint8List());
//       if (photo == null) throw Exception('Failed to load photo');

//       // 사진 크기를 프레임의 9/10로 조정
//       final photoSize = (MARKER_SIZE * 0.9).toInt(); // 72x72
//       final resizedPhoto =
//           img.copyResize(photo, width: photoSize, height: photoSize);

//       // 둥근 모서리 마스크 생성
//       final mask = img.Image(width: photoSize, height: photoSize);
//       img.fillCircle(mask,
//           x: photoSize ~/ 2,
//           y: photoSize ~/ 2,
//           radius: 20,
//           color: img.ColorRgba8(255, 255, 255, 255));

//       // 마스크 적용
//       for (var y = 0; y < photoSize; y++) {
//         for (var x = 0; x < photoSize; x++) {
//           final maskColor = mask.getPixel(x, y);
//           if (maskColor == 0) {
//             resizedPhoto.setPixel(x, y, 0 as img.Color);
//           }
//         }
//       }

//       // 최종 이미지 생성
//     final composite = img.Image(width: MARKER_SIZE.toInt(), height: MARKER_SIZE.toInt());
    
//     // 순서 변경: 먼저 프레임을 깔고
//     img.compositeImage(composite, frameResized);
    
//     // 그 위에 사진을 중앙에 배치
//     final x = (MARKER_SIZE.toInt() - photoSize) ~/ 2;
//     final y = (MARKER_SIZE.toInt() - photoSize) ~/ 2;
//     img.compositeImage(composite, resizedPhoto, dstX: x, dstY: y);

//     final bytes = img.encodePng(composite);
//     return BitmapDescriptor.fromBytes(bytes);
//   } catch (e) {
//     return await createMarkerIcon(FALLBACK_IMAGE, isCurrentUser);
//   }
//   }
// }
