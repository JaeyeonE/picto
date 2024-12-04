// lib/main.dart
import 'package:flutter/material.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/utils/app_color.dart';
import 'package:picto/views/sign_in/welcome_screen.dart'; // 추후 수정 예정
import 'package:picto/widgets/button/makers.dart';
import 'package:picto/models/user_manager/user.dart';
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

  final UserManagerService _userService = UserManagerService(host: 'http://3.35.153.213:8086');

  Future<User?> checkAuthState() async {
    try {
      final token = await _userService.getToken();
      if (token == null) return null;
      
      final userId = await _userService.getUserId();
      if (userId == null) return null;

      final userInfo = await _userService.getUserAllInfo(userId);
      return userInfo.user;
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
        onPopInvokedWithResult: (bool didPop, dynamic data) async {
          if (didPop) return Future.value(true);

          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('로그아웃'),
              content: const Text('앱을 종료하기 전에 로그아웃 하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _userService.deleteToken();
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

          return Future.value(shouldPop ?? false);
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