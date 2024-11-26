import 'package:flutter/material.dart';
import 'package:picto/widgets/screen_custom/folder/folder_list.dart';
import 'package:picto/widgets/screen_custom/folder/folder_header.dart';
import 'package:picto/widgets/screen_custom/folder/header_switch.dart';
import 'package:picto/widgets/screen_custom/folder/header_switch_content_box.dart';

class Folder extends StatefulWidget {
  final int? folderId;
  const Folder({super.key, this.folderId});

  @override
  State<Folder> createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  void initState() {
    super.initState(); // 폴더 목록 로드
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: FolderHeader(),
        body: Column(
          children: [
            HeaderSwitch(),
            Expanded(
              child: ContentView(),
            )
          ] 
        ),
      )
    );
  }
  
}
