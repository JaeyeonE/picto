import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class UpdateFolderDialog extends StatefulWidget {
  const UpdateFolderDialog({Key? key}) : super(key: key);

  @override
  State<UpdateFolderDialog> createState() => _UpdateFolderDialogState();
}

class _UpdateFolderDialogState extends State<UpdateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  late FolderViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FolderViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Folder'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Folder Name',
                hintText: 'Enter folder name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter folder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter folder description',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter folder description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await viewModel.updateFolder(
                viewModel.currentFolderId,
                _nameController.text,
                _contentController.text,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}