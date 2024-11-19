//Users/jaeyeon/workzone/picto/lib/main.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'views/map/map.dart';

Future<void> main() async {
  // 카카오맵 초기화
  await dotenv.load(fileName: ".env");
  AuthRepository.initialize(appKey: dotenv.env['KAKAO_JAVASCRIPT_KEY']!);
  runApp(const PhotoSharingApp());
}

class PhotoSharingApp extends StatelessWidget {
  const PhotoSharingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PICTO',
      theme: AppThemeExtension.appTheme,
      home: const MapScreen(),
    );
  }
}