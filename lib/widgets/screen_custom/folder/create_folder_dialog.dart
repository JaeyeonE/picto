import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({Key? key}) : super(key: key);

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  final FolderViewModel viewModel = Get.find<FolderViewModel>();

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Folder'),
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
              await viewModel.createFolder(
                _nameController.text,
                _contentController.text,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}