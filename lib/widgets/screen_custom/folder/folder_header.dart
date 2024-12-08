import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/utils/constant.dart';
import 'package:picto/widgets/screen_custom/folder/create_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/delete_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/enter_code_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/folder_user_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/share_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/update_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/manage_member_dialog.dart';

class FolderHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final String logoPath;

  const FolderHeader({
    Key? key,
    this.onBackPressed,
    this.onMenuPressed,
    this.logoPath = Constant.logoPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
        return AppBar(
          title: Builder(
            builder: (context) {
              final currentFolderName = viewModel.currentFolderName;
              
              if (currentFolderName == null || currentFolderName.isEmpty) {
                return Image.asset(
                  logoPath,
                  height: 32,
                  fit: BoxFit.contain,
                );
              }
              return Text(currentFolderName);
            },
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              final currentFolderName = viewModel.currentFolderName;
              
              if (currentFolderName == null || currentFolderName.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  viewModel.setCurrentFolder('', -1);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          actions: [
            Builder(
              builder: (context) {
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
              },
            ),
          ],
        );
      },
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
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const CreateFolderDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('enter invitation code'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const EnterCodeDialog(),
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
                builder: (context) => const UpdateFolderDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('manage member'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const ManageMemberDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('delete folder'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const DeleteFolderDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('share folder'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const ShareFolderDialog(),
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
                title: const Text('테스트 폴더 초대'),
                subtitle: const Text('홍길동님이 초대하셨습니다'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('거절', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
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