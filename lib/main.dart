//Users/jaeyeon/workzone/picto/lib/main.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:picto/views/sign_in/welcome_screen.dart';
import 'views/map/google_map.dart';

Future<void> main() async {
  // 카카오맵 초기화
  //await dotenv.load(fileName: ".env");
  // AuthRepository.initialize(appKey: dotenv.env['KAKAO_JAVASCRIPT_KEY']!);
  runApp(const PhotoSharingApp());
}

class PhotoSharingApp extends StatelessWidget {
  const PhotoSharingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PICTO',
      theme: AppThemeExtension.appTheme,
      home: const MapScreen(), //맵 스크린으로 수정 필요
    );
  }
}

// 이하 로그인 테스트용 main
// 최종 테스트 전 병합 필요! 지금은 서버 닫혀 있어서 바로 맵으로 이동!

// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:picto/views/sign_in/welcome_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PICTO',
//       theme: ThemeData(
//         // 테마 설정
//         primarySwatch: Colors.blue,
//       ),
//       home: const WelcomeScreen(), // WelcomeScreen 사용
//     );
//   }
// }
