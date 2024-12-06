//lib/main.dart

import 'package:flutter/material.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/utils/app_color.dart';
import 'package:picto/views/sign_in/login_screen.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/views/map/map.dart';
import 'package:picto/views/map/marker_image_processor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
  try {
    await MarkerImageProcessor.loadFrameImages();
    debugPrint('마커 이미지 초기화 성공');
  } catch (e) {
    debugPrint('마커 이미지 초기화 실패: $e');
=======
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
        Get.put(FolderViewModel(folderService: folderService, userId: 1));
      }),
    );
>>>>>>> folder
  }

  runApp(PhotoSharingApp());
}

class PhotoSharingApp extends StatelessWidget {
  PhotoSharingApp({super.key});

  final UserManagerService _userService =
      UserManagerService(host: 'http://3.35.153.213:8086');

  Future<User?> checkAuthState() async {
    try {
      final token = await _userService.getToken();
      if (token == null) return null;

      final userId = await _userService.getUserId();
      if (userId == null) return null;

      final userInfo = await _userService.getUserAllInfo(userId);
      return userInfo.user;
    } catch (e) {
      debugPrint('Auth check error: $e');
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

            if (snapshot.data == null) {
              return const LoginScreen();
            }

            return MapScreen(initialUser: snapshot.data!);
          },
        ),
      ),
<<<<<<< HEAD
=======
      body: const FolderList(userId: 1),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final FolderViewModel viewModel = Get.find<FolderViewModel>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새 폴더 만들기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '폴더 이름',
                  hintText: '폴더 이름을 입력하세요',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택사항)',
                  hintText: '폴더에 대한 설명을 입력하세요',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await viewModel.createFolder(
                    nameController.text,
                    descController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('만들기'),
            ),
          ],
        );
      },
>>>>>>> folder
    );
  }
}
