import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/widgets/screen_custom/folder/folder_list.dart';
import 'package:picto/widgets/screen_custom/folder/chat.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView>{
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<FolderViewModel>( // view
      builder: (context, viewModel, child) {
        return viewModel.isFirst
            ? const FolderList()
            : const Chat();
      },
    );
  }
}