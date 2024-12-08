import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/utils/constant.dart';
import 'package:picto/widgets/screen_custom/folder/create_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/delete_folder_dialog.dart';
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
    final currentFolderName = viewModel.currentFolderName;
    final currentFolderId = viewModel.currentFolderId;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            _showNotificationList(context);
            print('Notification pressed');
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            if(currentFolderId == null || currentFolderName == null || currentFolderName.isEmpty) {
              _showFolderListOptions(context); // 원래 이거임
              //_showFolderOptions(context);
            } else {
              _showFolderOptions(context);
            }
          },
        ),
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
              // go to member management
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
        ],
      ),
    );
  }
  
  void _showNotificationList(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 12),
              Text(
                '공유 폴더 알림 조회',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.folder_shared),
          title: const Text('테스트 폴더 초대'),  // 여기는 실제 폴더 이름이 들어갈 예정
          subtitle: const Text('홍길동님이 초대하셨습니다'),  // 여기는 실제 초대한 사람 이름이 들어갈 예정
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () {
                  Navigator.pop(context);
                  // 수락 로직 구현
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  // 거절 로직 구현
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}