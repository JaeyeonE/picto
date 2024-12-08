import 'package:flutter/material.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/session/session_service.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/utils/app_color.dart';
import 'package:picto/views/map/map.dart';
import 'package:picto/views/sign_in/login_screen.dart';

class PhotoSharingApp extends StatefulWidget {
  const PhotoSharingApp({super.key});

  @override
  State<PhotoSharingApp> createState() => _PhotoSharingAppState();
}

class _PhotoSharingAppState extends State<PhotoSharingApp> {
  final UserManagerService _userService = UserManagerService();
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _setupSessionListeners();
  }

  void _setupSessionListeners() {
    _sessionService.getStatusStream().listen((status) {
      debugPrint('WebSocket Status: $status');
    }, onError: (error) {
      debugPrint('WebSocket Status Error: $error');
    });

    _sessionService.getSessionStream().listen((message) {
      debugPrint('Received message: ${message.type}');
    }, onError: (error) {
      debugPrint('WebSocket Message Error: $error');
    });

  }

  Future<User?> checkAuthState() async {
    try {
      final token = await _userService.getToken();
      if (token == null) return null;

      final userId = await _userService.getUserId();
      if (userId == null) return null;

      final userInfo = await _userService.getUserAllInfo(userId);

      try {
        await _sessionService.initializeWebSocket(userId);
        await _sessionService.enterSession(userId);
      } catch (e) {
        debugPrint('Session initialization error: $e');
      }

      return userInfo.user;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return null;
    }
  }

  Future<void> _handleAppExit(BuildContext context, bool isLogout) async {
    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        await _sessionService.exitSession(userId);
      }
      _sessionService.dispose();

      if (isLogout) {
        await _userService.deleteToken();
      }

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('App exit error: $e');
      if (context.mounted) {
        Navigator.pop(context, false);
      }
    }
  }

  @override
  void dispose() {
    _sessionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PICTO',
      theme: AppThemeExtension.appTheme,
      home: WillPopScope(
        onWillPop: () async {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('앱 종료'),
              content: const Text('앱을 종료하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => _handleAppExit(context, true),
                  child: const Text('로그아웃 후 종료'),
                ),
                TextButton(
                  onPressed: () => _handleAppExit(context, false),
                  child: const Text('종료'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        },
        child: FutureBuilder<User?>(
          future: checkAuthState(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('오류가 발생했습니다: ${snapshot.error}'),
                ),
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
