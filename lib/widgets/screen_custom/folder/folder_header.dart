import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/utils/constant.dart';

class FolderHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final String logoPath;
  final FolderViewModel viewModel = Get.find<FolderViewModel>();

  FolderHeader({
    Key? key,
    this.onBackPressed,
    this.onMenuPressed,
    this.logoPath = Constant.logoPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Obx(() {
        final currentFolderName = viewModel.currentFolderName;
        
        // currentFolderName이 null이거나 비어있으면 로고를 표시
        if (currentFolderName == null || currentFolderName.isEmpty) {
          return Image.asset(
            logoPath,
            height: 32,
            fit: BoxFit.contain,
          );
        }
        // 폴더 이름이 있으면 표시
        return Text(currentFolderName);
      }),
      centerTitle: true,
      leading: Obx(() {
        final currentFolderName = viewModel.currentFolderName;
        
        // currentFolderName이 null이거나 비어있으면 뒤로가기 버튼을 숨김
        if (currentFolderName == null || currentFolderName.isEmpty) {
          return const SizedBox.shrink();
        }
        return IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로가기 시 폴더 이름 초기화
            viewModel.setCurrentFolder('', -1);
            if (onBackPressed != null) {
              onBackPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: onMenuPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}