import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FolderViewModel(FolderService()),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: FolderHeader(
            logoPath: 'assets/common/picto_letter_logo.png',
          ),
          body: const FolderList(),  // 우리가 만든 위젯
        ),
      ),
    );
  }
}