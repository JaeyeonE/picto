import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/widgets/screen_custom/folder/photo_list.dart';
import 'package:picto/widgets/screen_custom/folder/chat.dart';

class ContentView extends StatelessWidget {
  ContentView({super.key});

  final FolderViewModel viewModel = Get.find<FolderViewModel>();

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
        return viewModel.isPhotoMode
            ? PhotoListWidget(type: PhotoListType.folder, folderId: viewModel.currentFolderId!)
            : Chat(
                folderId: viewModel.currentFolderId,
                currentUserId: viewModel.user.userId,
              );
      },
    );
  }
}