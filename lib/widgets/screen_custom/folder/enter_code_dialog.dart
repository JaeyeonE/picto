import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class EnterCodeDialog extends StatefulWidget {
  const EnterCodeDialog({Key? key}) : super(key: key);

  @override
  State<EnterCodeDialog> createState() => _EnterCodeDialogState();
}

class _EnterCodeDialogState extends State<EnterCodeDialog> {
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';

  int? _getFolderIdFromCode(String code) {
    try {
      int numericCode = int.parse(code);
      if ((numericCode - 11) % 7 == 0) {
        return (numericCode - 11) ~/ 7;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _handleSubmit(BuildContext context) async {
    final viewModel = context.read<FolderViewModel>();
    final folderId = _getFolderIdFromCode(_codeController.text.trim());
    
    if (folderId != null) {
      try {
        await viewModel.joinFolderWithCode(_codeController.text.trim());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the folder!')),
        );
        viewModel.loadFolders();
      } catch (e) {
        setState(() {
          _errorMessage = 'Error joining folder. Please try again.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid invitation code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Invitation Code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Invitation Code',
              hintText: 'Enter the code you received',
            ),
            keyboardType: TextInputType.number,
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _handleSubmit(context),
          child: const Text('Join'),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}