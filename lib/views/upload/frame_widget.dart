import 'package:flutter/material.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/services/upload/frame_add_service.dart';
import 'package:picto/services/upload/frame_list.dart';
import 'package:picto/services/upload/frame_upload.dart';
import 'package:picto/views/upload/frame_item.dart';

class FrameSelectionWidget extends StatefulWidget {
  final Function(Photo frame, Map<String, dynamic> uploadData)? onFrameSelected;

  const FrameSelectionWidget({
    this.onFrameSelected,
    Key? key,
  }) : super(key: key);

  @override
  _FrameSelectionWidgetState createState() => _FrameSelectionWidgetState();
}

class _FrameSelectionWidgetState extends State<FrameSelectionWidget> {
  Photo? _selectedFrame;
  List<Photo> _frames = [];
  final FrameListService _frameListService = FrameListService();
  final FrameAddService _frameAddService = FrameAddService();
  bool _isLoading = false;
  Map<String, dynamic> _selectedFrameData = {};

  @override
  void initState() {
    super.initState();
    _loadFrames();
  }

  Future<void> _loadFrames() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final frames =
          await _frameListService.getFrames(2); // userId는 실제 사용자 ID로 변경 필요
      if (!mounted) return;
      setState(() {
        _frames = frames;
        _isLoading = false;
      });
    } catch (e) {
      print('프레임 로드 실패: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프레임 로드 실패: $e')),
      );
    }
  }

  Future<void> _handleAddFrame() async {
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const SaveLocationDialog(),
    );

    if (shouldProceed == true && mounted) {
      try {
        // 현재 위치 정보를 가져오는 로직 필요
        final double currentLat = 35.83569842525286; // 실제 위치로 변경 필요
        final double currentLng = 128.62260693482764; // 실제 위치로 변경 필요

        final frameData = await _frameAddService.addFrame();

        await _loadFrames();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치가 저장되었습니다.')),
        );
        _selectedFrameData = frameData;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  void _onFrameSelected(Photo? frame) {
    if (!mounted) return;
    setState(() => _selectedFrame = frame);

    if (frame == null) {
      _handleAddFrame();
    } else if (widget.onFrameSelected != null) {
      _selectedFrameData = {
        'photoId': frame.photoId,
        'location': frame.location,
        'registerTime': frame.registerDatetime,
      };
      widget.onFrameSelected!(frame, _selectedFrameData);
    }
  }

  @override
  void dispose() {
    _frameListService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: constraints.maxWidth * 0.7,
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: const Color(0xFF313233),
          borderRadius: BorderRadius.circular(4),
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<Photo>(
                    value: _selectedFrame,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    hint: const Text(
                      '저장된 액자',
                      style: TextStyle(color: Colors.grey),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    isExpanded: true,
                    items: [
                      if (_frames.length < 5)
                        DropdownMenuItem<Photo>(
                          child: Text(
                            _selectedFrame == null ? '현재 위치 저장' : '현재위치 액자로 저장',
                            style: TextStyle(
                              color: _selectedFrame == null
                                  ? const Color(0xFFFFD700)
                                  : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ..._frames.map((Photo frame) => FrameItem(frame: frame)),
                    ],
                    onChanged: _onFrameSelected,
                  ),
                ),
              ),
      ),
    );
  }
}
