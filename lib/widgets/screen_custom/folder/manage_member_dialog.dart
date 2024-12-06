import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class FolderUsersDialog extends StatefulWidget {
  const FolderUsersDialog({Key? key}) : super(key: key);

  @override
  State<FolderUsersDialog> createState() => _FolderUsersDialogState();
}

class _FolderUsersDialogState extends State<FolderUsersDialog> {
  final FolderViewModel viewModel = Get.find<FolderViewModel>();

  @override
  void initState() {
    super.initState();
    _loadFolderUsers();
  }

  Future<void> _loadFolderUsers() async {
    await viewModel.loadFolderUsers(viewModel.currentFolderId);
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
                  itemCount: viewModel.folderUsers.length,
                  itemBuilder: (context, index) {
                    final user = viewModel.folderUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      // 폴더 생성자인 경우 표시
                      trailing: user.role == 'OWNER' 
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