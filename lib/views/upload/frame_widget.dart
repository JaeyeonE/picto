import 'package:flutter/material.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/services/upload/frame_add_service.dart';
import 'package:picto/services/upload/frame_list.dart';
import 'package:picto/services/upload/frame_upload.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/views/upload/frame_item.dart';

class FrameSelectionWidget extends StatefulWidget {
  final Function(Photo?) onFrameSelected;
  const FrameSelectionWidget({
    Key? key,
    required this.onFrameSelected,
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
  final UserManagerService _userManager = UserManagerService();
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadFrames();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    userId = await _userManager.getUserId();
  }

  Future<void> _loadFrames() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final frames = await _frameListService.getFrames(userId);
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
        await _frameAddService.addFrame();
        await _loadFrames();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치가 저장되었습니다.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  void _onSelected(String? value) {
    if (!mounted) return;

    if (value == null) return;

    if (value == 'clear') {
      setState(() => _selectedFrame = null);
      widget.onFrameSelected(null); // 부모에게 null 전달
    } else if (value == 'add_new') {
      _handleAddFrame();
    } else {
      // 실제 프레임 선택
      final selectedFrame = _frames.firstWhere(
        (frame) => frame.photoId.toString() == value,
        orElse: () => _frames[0],
      );
      setState(() => _selectedFrame = selectedFrame);
      widget.onFrameSelected(selectedFrame); // 부모에게 선택된 프레임 전달
    }
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
                  child: DropdownButton<String>(
                    value:
                        _selectedFrame?.photoId.toString(), // photoId를 문자열로 변환
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    hint: const Text(
                      '저장된 액자',
                      style: TextStyle(color: Colors.grey),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'clear',
                        child: Text(
                          '선택 안함',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ..._frames.map((Photo frame) => DropdownMenuItem<String>(
                            value: frame.photoId.toString(), // photoId를 문자열로 변환
                            child: Text(
                              frame.location ?? '위치 정보 없음',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )),
                      if (_frames.length < 5)
                        const DropdownMenuItem<String>(
                          value: 'add_new',
                          child: Text(
                            '현재위치 액자로 저장',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                    onChanged: _onSelected,
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _frameListService.dispose();
    super.dispose();
  }
}
