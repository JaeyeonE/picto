import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/utils/constant.dart';
import 'package:picto/widgets/screen_custom/folder/create_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/delete_folder_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/folder_user_dialog.dart';
import 'package:picto/widgets/screen_custom/folder/invite_user_dialog.dart';
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
                  height: 20,
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
                        if (viewModel.currentFolderName == null || viewModel.currentFolderName!.isEmpty || folderId == null || folderId == -1){
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
  final viewModel = Provider.of<FolderViewModel>(context, listen: false);
  
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
              builder: (context) => ChangeNotifierProvider<FolderViewModel>.value(
                value: viewModel,
                child: const CreateFolderDialog(),
              ),
            );
          },
        ),
      ],
    ),
  );
}


  void _showFolderOptions(BuildContext context) {
    final viewModel = Provider.of<FolderViewModel>(context, listen: false);
    
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
                builder: (context) => ChangeNotifierProvider<FolderViewModel>.value(
                  value: viewModel,
                  child: const UpdateFolderDialog(),
                ),
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
                builder: (context) => ChangeNotifierProvider<FolderViewModel>.value(
                  value: viewModel,
                  child: const DeleteFolderDialog(),
                ),
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
                builder: (context) => ChangeNotifierProvider<FolderViewModel>.value(
                  value: viewModel,
                  child: const InviteUserDialog(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showNotificationDialog(BuildContext context) {
  final viewModel = Provider.of<FolderViewModel>(context, listen: false);
  
  // 초대 목록 로드
  viewModel.loadInvitation(viewModel.user.userId);

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
      content: Consumer<FolderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.invitations.isEmpty) {
            return const Center(
              child: Text('새로운 초대가 없습니다.'),
            );
          }

          return SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: viewModel.invitations.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final invite = viewModel.invitations[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.folder_shared),
                      title: Text('${invite.folderName} 초대'),
                      subtitle: Text('폴더에 초대되었습니다.'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await viewModel.acceptInvitation(invite.id, false);
                              // 초대 목록 새로고침
                              await viewModel.loadInvitation(viewModel.user.userId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('초대를 거절했습니다.')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('오류가 발생했습니다: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('거절', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            try {
                              await viewModel.acceptInvitation(invite.id, true);
                              // 초대 수락 후 폴더 목록 새로고침
                              await viewModel.loadFolders();
                              // 초대 목록 새로고침
                              await viewModel.loadInvitation(viewModel.user.userId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('초대를 수락했습니다.')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('오류가 발생했습니다: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('수락', style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}