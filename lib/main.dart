import 'package:flutter/material.dart';
import 'package:picto/app.dart';
import 'package:picto/views/map/marker_image_processor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await MarkerImageProcessor.loadFrameImages();
    debugPrint('마커 이미지 초기화 성공');
  } catch (e) {
    debugPrint('마커 이미지 초기화 실패: $e');
  }

  runApp(const PhotoSharingApp());
}

// main 분리