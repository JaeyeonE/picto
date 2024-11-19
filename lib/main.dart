//Users/jaeyeon/workzone/picto/lib/main.dart

import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'views/map/map.dart';

void main() {
  // 카카오맵 초기화
  AuthRepository.initialize(appKey: 'ee1e40cc66b1258bec033ba99af44f25');
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