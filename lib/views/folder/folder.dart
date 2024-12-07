import 'package:flutter/material.dart';

import 'package:picto/models/user_manager/user.dart';
import 'package:picto/widgets/screen_custom/folder/folder_list.dart';
import 'package:picto/widgets/screen_custom/folder/folder_header.dart';
import 'package:picto/widgets/screen_custom/folder/header_switch.dart';
import 'package:picto/widgets/common/navigation.dart';
import 'package:picto/widgets/screen_custom/folder/header_switch_content_box.dart';

class Folder extends StatefulWidget {
  final int? folderId;
  final User? user;
  const Folder({super.key, this.folderId, this.user});

  @override
  State<Folder> createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  void initState() {
    super.initState(); // 폴더 목록 로드
  }
  int selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FolderHeader(),
      body: Column(
        children: [
          HeaderSwitch(),
          Expanded(
            child: ContentView(),
          )
        ] 
      ),
    );
  }
  
}
