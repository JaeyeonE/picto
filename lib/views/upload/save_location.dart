import 'package:flutter/material.dart';

class SaveLocationDialog extends StatelessWidget {
  const SaveLocationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '위치 저장',
        style: TextStyle(color: Colors.white),
      ),
      content:
          const Text('현재 위치를 저장하시겠습니까?', style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF313233),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('아니오', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text(
            '네',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
