import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
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
  int selectedIndex = 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 상위 위젯에서 Provider 가져오기
    final viewModel = Provider.of<FolderViewModel>(context, listen: false);
    
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Consumer<FolderViewModel>(
            builder: (context, vm, _) => FolderHeader(),
          ),
        ),
        body: Column(
          children: [
            Consumer<FolderViewModel>(
              builder: (context, vm, _) => HeaderSwitch(),
            ),
            Expanded(
              child: Consumer<FolderViewModel>(
                builder: (context, vm, _) => ContentView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}