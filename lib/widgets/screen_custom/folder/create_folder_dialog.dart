import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class CreateFolderDialog extends StatefulWidget {
  final VoidCallback? onFolderCreated;  // Add callback for folder creation
  
  const CreateFolderDialog({
    Key? key,
    this.onFolderCreated,
  }) : super(key: key);

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isCreating = false;  // Add loading state

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
              enabled: !_isCreating,  // Disable during creation
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
              enabled: !_isCreating,  // Disable during creation
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
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isCreating
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isCreating = true;
                    });
                    
                    try {
                      final viewModel = context.read<FolderViewModel>();
                      await viewModel.createFolder(
                        _nameController.text,
                        _contentController.text,
                      );
                      
                      // Explicitly reload folders
                      await viewModel.loadFolders();
                      
                      // Call the callback if provided
                      widget.onFolderCreated?.call();
                      
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isCreating = false;
                        });
                      }
                    }
                  }
                },
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}