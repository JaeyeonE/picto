// lib/views/map/map_marker_temp.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerTemp {
  static Future<Set<Marker>> getDummyMarkers(String locationType) async {
    final pictoBorder = await getBytesFromAsset('lib/assets/map/my_picto.png', 60);
    final dogImage = await getBytesFromAsset('lib/assets/map/dog.png', 56);

    final markers = <Marker>{};
    
    switch (locationType) {
      case 'large':
        markers.add(await createCustomMarker(
          LatLng(35.8714, 128.6014), // 대구시
          pictoBorder,
          dogImage,
          'large_marker',
          '대구시 마커',
        ));
        break;
      case 'middle':
        markers.add(await createCustomMarker(
          LatLng(35.8292, 128.5355), // 달서구
          pictoBorder,
          dogImage,
          'middle_marker',
          '달서구 마커',
        ));
        break;
      case 'small':
        markers.add(await createCustomMarker(
          LatLng(35.8579, 128.4871), // 계명대
          pictoBorder,
          dogImage,
          'small_marker',
          '계명대 마커',
        ));
        break;
    }

    return markers;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  static Future<Marker> createCustomMarker(
    LatLng position,
    Uint8List pictoBorder,
    Uint8List image,
    String markerId,
    String title,
  ) async {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: BitmapDescriptor.fromBytes(
        await combineImages(pictoBorder, image),
      ),
      infoWindow: InfoWindow(title: title),
    );
  }

  static Future<Uint8List> combineImages(
    Uint8List background,
    Uint8List foreground,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final backgroundImage = await decodeImageFromList(background);
    final foregroundImage = await decodeImageFromList(foreground);
    
    // 배경 이미지(프레임) 그리기
    canvas.drawImage(backgroundImage, Offset.zero, Paint());
    
    // 전경 이미지(강아지) 그리기 - 약간의 오프셋으로 중앙에 위치
    canvas.drawImage(
      foregroundImage,
      const Offset(2, 2), // 프레임 내부에 맞게 조정
      Paint(),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(60, 60);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
}