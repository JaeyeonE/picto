import 'package:flutter/material.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class InviteUserDialog extends StatefulWidget {
  const InviteUserDialog({Key? key}) : super(key: key);

  @override
  _InviteUserDialogState createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final TextEditingController _emailController = TextEditingController();
  User? _foundUser;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('사용자 초대'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: '초대할 사용자의 이메일을 입력하세요',
            ),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          if (_foundUser != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(_foundUser!.name),
              subtitle: Text(_foundUser!.email),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            final email = _emailController.text.trim();
            if (email.isEmpty) {
              setState(() {
                _error = '이메일을 입력해주세요';
              });
              return;
            }

            final viewModel = context.read<FolderViewModel>();
            try {
              final user = await viewModel.searchUserByEmail(email);
              if (user != null) {
                setState(() {
                  _foundUser = user;
                  _error = null;
                });

                // 사용자를 찾았으면 초대 보내기
                try {
                  await viewModel.inviteUserToFolder(
                    user.userId,
                    viewModel.currentFolderId,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('초대를 보냈습니다')),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _error = '초대 전송 중 오류가 발생했습니다';
                  });
                }
              } else {
                setState(() {
                  _foundUser = null;
                  _error = '사용자를 찾을 수 없습니다';
                });
              }
            } catch (e) {
              setState(() {
                _foundUser = null;
                _error = '사용자 검색 중 오류가 발생했습니다';
              });
            }
          },
          child: const Text('초대'),
        ),
      ],
    );
  }
}