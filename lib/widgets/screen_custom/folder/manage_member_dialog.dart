import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/models/user_manager/user.dart';

class ManageMemberDialog extends StatefulWidget {
  const ManageMemberDialog({Key? key}) : super(key: key);

  @override
  State<ManageMemberDialog> createState() => _ManageMemberDialogState();
}

class _ManageMemberDialogState extends State<ManageMemberDialog> {
  final FolderViewModel viewModel = Get.find<FolderViewModel>();

  @override
  void initState() {
    super.initState();
    _loadFolderUsers();
  }

  Future<void> _loadFolderUsers() async {
    await viewModel.loadFolderUsers(viewModel.currentFolderId);
  }

  Widget _buildAvatar(User user) {
    if (user.profilePath != null && user.profilePath!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: AssetImage(user.profilePath!),
        backgroundColor: Colors.grey[200],
      );
    } else {
      return CircleAvatar(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        ),
        backgroundColor: Colors.grey[200],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '폴더 멤버',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (viewModel.folderUsers.isEmpty) {
                  return const Center(
                    child: Text('폴더에 멤버가 없습니다.'),
                  );
                }

                return ListView.builder(
                  itemCount: viewModel.userProfiles.length,
                  itemBuilder: (context, index) {
                    final user = viewModel.userProfiles[index];
                    return ListTile(
                      leading: _buildAvatar(user),
                      title: Text(user.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          if (user.accountName != null && user.accountName!.isNotEmpty)
                            Text('계정명: ${user.accountName}'),
                        ],
                      ),
                      isThreeLine: user.accountName != null && user.accountName!.isNotEmpty,
                      trailing: user.userId == viewModel.user.userId 
                        ? const Chip(
                            label: Text('폴더 생성자'),
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white),
                          )
                        : null,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}