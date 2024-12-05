import 'package:flutter/material.dart';
import 'package:picto/services/frame_service.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/views/upload/save_location.dart';

class DropDownWidget extends StatefulWidget {
  const DropDownWidget({Key? key}) : super(key: key);

  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String? _selectedFrame;
  List<Photo> _frames = [];
  final FrameService _frameService = FrameService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFrames();
  }

  Future<void> _loadFrames() async {
    try {
      final frames = await _frameService.getUserFrames(2);
      setState(() {
        _frames = frames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('프레임 로드 실패: $e');
    }
  }

  Future<void> _handleAddFrame() async {
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => const SaveLocationDialog(),
    );

    if (shouldProceed == true) {
      try {
        await _frameService.saveLocationAsFrame();

        await _loadFrames();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('현재 위치가 프레임으로 저장되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('위치 저장 실패: $e')),
          );
        }
      }
    }
  }

  void _onFrameSelected(String value) {
    if (value == 'add_frame') {
      _handleAddFrame();
    } else {
      setState(() {
        _selectedFrame = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return PopupMenuButton<String>(
      onSelected: _onFrameSelected,
      color: const Color(0xFF313233),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF313233),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedFrame ?? '저장된 액자',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return [
          ..._frames.where((frame) => frame.tag != null).map((frame) {
            return PopupMenuItem<String>(
              value: frame.tag!,
              child:
                  Text(frame.tag!, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          if (_frames.isNotEmpty)
            const PopupMenuItem(
              enabled: false,
              child: Divider(),
            ),
          PopupMenuItem(
            value: 'add_frame',
            child: Center(
              child: Text(
                '현재 위치 저장',
                style: TextStyle(color: Color.fromARGB(255, 255, 198, 41)),
              ),
            ),
          ),
        ];
      },
    );
  }
}
