import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:picto/models/user_manager/user.dart';

import 'package:picto/services/folder_service.dart';
import 'package:picto/services/photo_store.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/widgets/screen_custom/folder/folder_list.dart';
import 'package:picto/widgets/screen_custom/folder/folder_header.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dio 설정
  final dio = Dio()
    ..options = BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    );

  // Services
  final folderService = FolderService(dio);
  final photoStore = PhotoStoreService(baseUrl: 'http://52.78.237.242:8084');
  final userManager = UserManagerService(host: 'http://3.35.153.213:8086');
  User user = await userManager.getUserProfile(1);

  // ViewModel
  final folderViewModel = FolderViewModel(
    userManagerService: userManager, 
    photoStoreService: photoStore, 
    folderService: folderService,
    user: user
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => folderViewModel,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FolderViewModel>(context);
    
    return Scaffold(
      appBar: FolderHeader(
        onBackPressed: null,
        onMenuPressed: () {
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
              ],
            ),
          );
        },
      ),
      body: FolderList(user: viewModel.user),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final viewModel = Provider.of<FolderViewModel>(context, listen: false);

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