import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/utils/constant.dart';
import 'package:picto/widgets/screen_custom/folder/create_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/delete_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/enter_code_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/folder_user_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/share_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/update_folder_dialog.dart';

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
          Navigator.of(context).pop();
        },
      );
    }),
    actions: [
  Obx(() {
    final folderId = viewModel.currentFolderId;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            _showNotificationDialog(context);
            print('Notification pressed');
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            if (folderId == null) {
              _showFolderListOptions(context);
            } else {
              _showFolderOptions(context);
            }
          },
        )
      ],
    );
  }),
],
  );
}

  void _showFolderListOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.create_new_folder),
          title: const Text('Create New Folder'),
          onTap: () {
            Navigator.pop(context); // Close bottom sheet
            showDialog(
              context: context,
              builder: (context) => const CreateFolderDialog(),
            );
          },
        ),
      ],
    ),
  );
}

  void _showFolderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('edit folder info'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) =>const UpdateFolderDialog(),
              );
            },
          ),
          ListTile (
            leading: const Icon(Icons.people),
            title: const Text('manage member'),
            onTap:() {
              Navigator.pop(context);
              showDialog(
              context: context,
              builder: (context) => const FolderUserDialog(),
            );
            },
          ),
          ListTile (
            leading: const Icon(Icons.delete),
            title: const Text('delete folder'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) =>const DeleteFolderDialog(),
              );
            },
          ),
          ListTile (
            leading: const Icon(Icons.share),
            title: const Text('share folder'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) =>const ShareFolderDialog(),
              );
            },
          ),
          ListTile (
            leading: const Icon(Icons.share),
            title: const Text('enter invitation code'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) =>const EnterCodeDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, size: 24),
            SizedBox(width: 8),
            Text('공유 폴더 알림'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              ListTile(
                leading: const Icon(Icons.folder_shared),
                title: const Text('테스트 폴더 초대'),  // 실제 폴더 이름
                subtitle: const Text('홍길동님이 초대하셨습니다'),  // 실제 초대한 사람 이름
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 거절 로직
                    },
                    child: const Text('거절', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 수락 로직
                    },
                    child: const Text('수락', style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}