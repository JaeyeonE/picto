import 'package:flutter/material.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/services/session_service.dart';  // 추가
import 'package:picto/utils/app_color.dart';
import 'package:picto/views/sign_in/login_screen.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/views/map/map.dart';
import 'package:picto/views/map/marker_image_processor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await MarkerImageProcessor.loadFrameImages();
    debugPrint('마커 이미지 초기화 성공');
  } catch (e) {
    debugPrint('마커 이미지 초기화 실패: $e');
  }

  runApp(PhotoSharingApp());
}

class PhotoSharingApp extends StatelessWidget {
  PhotoSharingApp({super.key});

  final UserManagerService _userService =
      UserManagerService(host: 'http://3.35.153.213:8086');
  final SessionService _sessionService = SessionService();

  Future<User?> checkAuthState() async {
    try {
      final token = await _userService.getToken();
      if (token == null) return null;

      final userId = await _userService.getUserId();
      if (userId == null) return null;

      final userInfo = await _userService.getUserAllInfo(userId);
      
      // 사용자 인증이 확인되면 세션 서비스 초기화
      await _sessionService.initializeWebSocket(userId);
      await _sessionService.enterSession(userId);
      
      return userInfo.user;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return null;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        await _sessionService.exitSession(userId);
      }
      _sessionService.dispose();
      await _userService.deleteToken();
    } catch (e) {
      debugPrint('Logout error: $e');
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
                    await _handleLogout(context);
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('네'),
                ),
                TextButton(
                  onPressed: () async {
                    // '아니오'를 선택한 경우에도 세션은 종료
                    try {
                      final userId = await _userService.getUserId();
                      if (userId != null) {
                        await _sessionService.exitSession(userId);
                      }
                      _sessionService.dispose();
                    } catch (e) {
                      debugPrint('Session closure error: $e');
                    }
                    if (context.mounted) {
                      Navigator.pop(context, false);
                    }
                  },
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

            if (snapshot.data == null) {
              return const LoginScreen();
            }

            return MapScreen(initialUser: snapshot.data!);
          },
        ),
      ),
    );
  }
}