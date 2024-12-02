// lib/main.dart
import 'package:flutter/material.dart';
import 'package:picto/services/user_manager.dart';
import 'package:picto/utils/app_color.dart';
import 'package:picto/views/sign_in/welcome_screen.dart';
import 'package:picto/widgets/button/makers.dart';
import 'package:picto/models/common/user.dart';
import 'views/map/map.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await MapMarkers.initializeMarkerImages();
    debugPrint('마커 이미지 초기화 성공');
  } catch (e) {
    debugPrint('마커 이미지 초기화 실패: $e');
  }
  
  runApp(PhotoSharingApp());
}

class PhotoSharingApp extends StatelessWidget {
  PhotoSharingApp({super.key});

  final UserManager _userManager = UserManager();

  Future<User?> checkAuthState() async {
    try {
      final token = await _userManager.getToken();
      if (token == null) return null;
      
      return await _userManager.getCurrentUser();
    } catch (e) {
      print('Auth check error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PICTO',
      theme: AppThemeExtension.appTheme,
      home: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) return;

          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('로그아웃'),
              content: const Text('앱을 종료하기 전에 로그아웃 하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _userManager.logout();
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('네'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('아니오'),
                ),
              ],
            ),
          );

          if (shouldPop ?? false) {
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
        child: FutureBuilder<User?>(
          future: checkAuthState(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            return const MapScreen();
          },
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:picto/utils/app_color.dart';
// import 'package:picto/views/sign_in/welcome_screen.dart';
// import 'package:picto/widgets/button/makers.dart';
// import 'views/map/map.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await MapMarkers.initializeMarkerImages();
//   runApp(const PhotoSharingApp());
// }

// class PhotoSharingApp extends StatelessWidget {
//   const PhotoSharingApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PICTO',
//       theme: AppThemeExtension.appTheme,
//       home: const MapScreen(), //맵 스크린으로 수정 필요
//     );
//   }
// }

// // 이하 로그인 테스트용 main
// // 최종 테스트 전 병합 필요! 지금은 서버 닫혀 있어서 바로 맵으로 이동!

// // // lib/main.dart
// // import 'package:flutter/material.dart';
// // import 'package:picto/views/sign_in/welcome_screen.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'PICTO',
// //       theme: ThemeData(
// //         // 테마 설정
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const WelcomeScreen(), // WelcomeScreen 사용
// //     );
// //   }
// // }
