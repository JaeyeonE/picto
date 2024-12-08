import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class DeleteFolderDialog extends StatefulWidget {
  const DeleteFolderDialog({Key? key}) : super(key: key);

  @override
  State<DeleteFolderDialog> createState() => _DeleteFolderDialogState();
}

class _DeleteFolderDialogState extends State<DeleteFolderDialog> {
  bool _showConfirmInput = false;
  bool _showFinalConfirmation = false;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleFirstConfirmation() {
    setState(() {
      _showConfirmInput = true;
    });
  }

  void _handleSecondConfirmation(FolderViewModel viewModel) {
    if (_textController.text == viewModel.currentFolderName) {
      setState(() {
        _showFinalConfirmation = true;
      });
    }
  }

  void _handleDelete(BuildContext context, FolderViewModel viewModel) async {
    Navigator.of(context).pop();
    await viewModel.deleteFolder(viewModel.currentFolderId);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${viewModel.currentFolderName}' 폴더가 삭제되었습니다"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
        final folderName = viewModel.currentFolderName;

        if (_showFinalConfirmation) {
          return AlertDialog(
            title: const Text('폴더 삭제 확인'),
            content: Text("'$folderName' 폴더가 삭제됩니다."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => _handleDelete(context, viewModel),
                child: const Text('예'),
              ),
            ],
          );
        }

        if (!_showConfirmInput) {
          return AlertDialog(
            title: const Text('폴더 삭제 확인'),
            content: const Text(
              '폴더를 정말 삭제하시겠습니까?\n유저정보 및 사진들이 삭제되며, 복구할 수 없습니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: _handleFirstConfirmation,
                child: const Text('예'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('폴더 삭제 확인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("'$folderName' 폴더가 삭제됩니다."),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: folderName,
                  labelText: '폴더 이름을 입력하세요',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => _handleSecondConfirmation(viewModel),
              child: const Text('예'),
            ),
          ],
        );
      },
    );
  }
}