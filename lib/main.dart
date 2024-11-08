import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/services/folder_service.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/widgets/screen_custom/folder/folder_list.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FolderViewModel(FolderService()),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('TEAM 200대의 공유 폴더'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // 뒤로가기 처리
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // 메뉴 처리
                },
              ),
            ],
          ),
          body: const FolderListView(),  // 우리가 만든 위젯
        ),
      ),
    );
  }
}