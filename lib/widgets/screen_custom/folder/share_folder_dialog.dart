import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class ShareFolderDialog extends StatelessWidget {
  const ShareFolderDialog({Key? key}) : super(key: key);

  String _generateInviteCode(int? folderId) {
    if (folderId == null) return '';
    return (folderId * 7 + 11).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
        final inviteCode = _generateInviteCode(viewModel.currentFolderId);

        return AlertDialog(
          title: const Text('Share Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share this invitation code with others:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      inviteCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied to clipboard')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.insert_invitation_sharp),
                      onPressed: () {
                        viewModel.inviteUserToFolder(2, viewModel.currentFolderId);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}