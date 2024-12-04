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
        Get.put(FolderViewModel(folderService));
      }),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FolderHeader(
        onBackPressed: null, // 메인 화면에서는 뒤로가기 버튼 비활성화
        onMenuPressed: () {
          // 메뉴 버튼 처리
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.create_new_folder),
                  title: const Text('새 폴더 만들기'),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateFolderDialog(context);
                  },
                ),
                // 추가 메뉴 아이템...
              ],
            ),
          );
        },
      ),
      body: const FolderList(),
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
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:picto/widgets/screen_custom/folder/chat.dart';  // Chat 위젯이 있는 파일 경로를 적절히 수정해주세요

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(  // GetX를 사용하므로 MaterialApp 대신 GetMaterialApp 사용
//       title: 'Chat App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 1,
//         ),
//       ),
//       home: Chat(
//         currentUserId: 2,  // 실제 사용시에는 로그인한 사용자의 ID를 전달
//         folderId: 487,      // 실제 사용시에는 선택된 폴더/채팅방의 ID를 전달
//       ),
//     );
//   }
// }