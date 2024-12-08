import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class FolderUserDialog extends StatelessWidget {
  const FolderUserDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 FolderViewModel 인스턴스 가져오기
    final viewModel = Provider.of<FolderViewModel>(context, listen: false);

    return AlertDialog(
      title: const Text('폴더 멤버'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<void>(
          future: viewModel.loadFolderUsers(viewModel.currentFolderId),
          builder: (context, snapshot) {
            // Consumer를 사용하여 folderUsers 리스트의 변화를 감지
            return Consumer<FolderViewModel>(
              builder: (context, model, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: model.folderUsers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(model.folderUsers[index].userId.toString()),
                    );
                  },
                );
              },
            );
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