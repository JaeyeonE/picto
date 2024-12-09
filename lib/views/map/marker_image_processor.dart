import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:picto/utils/app_color.dart';

class MarkerImageProcessor {
  static const double MARKER_SIZE = 110.0;
  static const double PHOTO_SIZE = 80.0;
  static const double PADDING = 10.0;
  static const double CORNER_RADIUS = 15.0;
  static const String FALLBACK_IMAGE = 'lib/assets/map/dog.png';

  static Future<BitmapDescriptor> createMarkerIcon(bool isCurrentUser) async {
    try {
      final photoBytes = await rootBundle.load(FALLBACK_IMAGE);
      final photo = img.decodeImage(photoBytes.buffer.asUint8List());
      if (photo == null) throw Exception('Failed to load photo');

      final paddedSize = PHOTO_SIZE + (PADDING * 2);
      final resizedPhoto = img.copyResize(photo, width: PHOTO_SIZE.toInt(), height: PHOTO_SIZE.toInt());
      
      final composite = img.Image(
        width: paddedSize.toInt(),
        height: paddedSize.toInt(),
        format: img.Format.uint8,
      );
      
      // Create a mask for rounded corners
      final mask = img.Image(width: paddedSize.toInt(), height: paddedSize.toInt());
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

      // Apply mask for rounded corners
      for (var y = 0; y < paddedSize.toInt(); y++) {
        for (var x = 0; x < paddedSize.toInt(); x++) {
          final maskColor = mask.getPixel(x, y);
          if (maskColor == 0) {
            composite.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
          }
        }
      }
      
      img.compositeImage(composite, resizedPhoto, 
          dstX: PADDING.toInt(), 
          dstY: PADDING.toInt());

      final bytes = img.encodePng(composite);
      return BitmapDescriptor.fromBytes(bytes);
    } catch (e) {
      throw Exception('Failed to create marker icon: $e');
    }
  }
}