import 'package:flutter/material.dart';
import 'package:picto/widgets/screen_custom/folder/folder_list.dart';
import 'package:picto/widgets/screen_custom/folder/folder_header.dart';
import 'package:picto/widgets/screen_custom/folder/header_switch.dart';
import 'package:picto/widgets/common/navigation.dart';

class Folder extends StatefulWidget {
  const Folder({super.key});

  @override
  State<Folder> createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  void initState() {
    super.initState(); // 폴더 목록 로드
  }
  int selectedIndex = 3;

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: FolderHeader(),
        body: Column(
          children: [
            HeaderSwitch(), 
            FolderList(), 
          ] 
        ),
        bottomNavigationBar: CustomNavigationBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      )
    );
  }
  
}
