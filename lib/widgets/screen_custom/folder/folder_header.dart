import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/utils/constant.dart';

class FolderHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final String logoPath; // 로고 이미지 경로

  const FolderHeader({
    Key? key,
    this.onBackPressed,
    this.onMenuPressed,
    this.logoPath = Constant.logoPath, // 로고 이미지 경로를 기본값으로 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderViewModel>(
      builder: (context, viewmodel, child) {
        return AppBar(
          title: viewmodel.currentFolderName == null
              ? Image.asset(
                  logoPath,
                  height: 32, // 로고 이미지 높이 조절
                  fit: BoxFit.contain,
                )
              : Text(viewmodel.currentFolderName!),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed ?? () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: onMenuPressed,
            ),
          ],
        );
      }
    );
    
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}