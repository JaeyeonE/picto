import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:picto/services/folder_service.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/widgets/screen_custom/folder/folder_list.dart';
import 'package:picto/widgets/screen_custom/folder/folder_header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Picto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const MainScreen(),
      initialBinding: BindingsBuilder(() {
        // Dio 설정
        final dio = Dio()
          ..options = BaseOptions(
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          );

        // Services
        final folderService = FolderService(dio);

        // ViewModels
        Get.put(FolderViewModel(folderService: folderService, userId: 2));
      }),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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