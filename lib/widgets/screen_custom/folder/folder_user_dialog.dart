import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class FolderUserDialog extends StatelessWidget {
  const FolderUserDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<FolderViewModel>();

    return AlertDialog(
      title: const Text('폴더 멤버'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<void>(
          future: viewModel.loadFolderUsers(viewModel.currentFolderId),
          builder: (context, snapshot) {
            return Obx(() {
              // if (viewModel.isLoading) {
              //   return const Center(child: CircularProgressIndicator());
              // }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: viewModel.folderUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(viewModel.folderUsers[index].userId.toString()),
                  );
                },
              );
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}