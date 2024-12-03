import 'package:flutter/material.dart';
import 'package:picto/services/frame_list.dart';

class DropDownWidget extends StatefulWidget {
  const DropDownWidget({Key? key}) : super(key: key);

  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String? _selectedFrame;
  final FrameService _frameService = FrameService();
  List<String> _frames = [];

  @override
  void initState() {
    super.initState();
    _fetchFrames();
  }

  Future<void> _fetchFrames() async {
    try {
      List<String> frames = await _frameService.getUserFrames(1);
      setState(() {
        _frames = frames;
      });
    } catch (e) {
      print('액자 가져오기 실패: $e');
    }
  }

  void _onFrameSelected(String value) {
    setState(() {
      _selectedFrame = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: _onFrameSelected,
      color: Color(0xFF313233),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF313233),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedFrame ?? '저장된 액자',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return [
          ..._frames.map((String album) {
            return PopupMenuItem<String>(
              value: album,
              child: Text(album, style: TextStyle(color: Colors.white)),
            );
          }).toList(),
          const PopupMenuItem(
            enabled: false,
            child: Divider(),
          ),
          PopupMenuItem(
            value: 'add',
            child: Center(
              child: Text('현재 위치 저장',
                  style: TextStyle(color: Color.fromARGB(255, 255, 198, 41))),
            ),
          ),
        ];
      },
    );
  }
}
