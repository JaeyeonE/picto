import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picto/models/photo_manager/photo.dart';

class FrameItem extends DropdownMenuItem<Photo> {
  FrameItem({
    required Photo frame,
    Key? key,
  }) : super(
          key: key,
          value: frame,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  frame.location ?? '위치 정보 없음',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(
                  DateTime.fromMillisecondsSinceEpoch(frame.registerDatetime),
                ),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
}

class SaveLocationDialog extends StatelessWidget {
  const SaveLocationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF313233),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      title: const Text(
        '위치 저장',
        style: TextStyle(color: Colors.grey),
      ),
      content: const Text(
        '현재 위치를 저장하시겠습니까?',
        style: TextStyle(color: Colors.grey),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            '아니오',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            '네',
            style: TextStyle(color: Color(0xFFFFD700)),
          ),
        ),
      ],
    );
  }
}
