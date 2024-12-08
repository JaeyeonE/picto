import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/services/upload/frame_list.dart';
import 'package:picto/services/upload/frame_upload.dart';
import 'upload_manager.dart';
import 'package:picto/views/upload/frame_widget.dart';
import 'package:picto/services/upload/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final UploadController _controller = UploadController();
  final ImageUploadService _uploadService = ImageUploadService();
  final FrameUploadService _frameUploadService = FrameUploadService();
  final FrameListService _frameListService = FrameListService();
  Photo? _selectedFrame;

  @override
  void initState() {
    super.initState();
    _controller.loadPhotos().then((_) => setState(() {}));
  }

  Future<void> _uploadImage(File file) async {
    if (_controller.image == null) return;

    try {
      String response;

      if (_selectedFrame != null) {
        // 프레임이 선택된 경우 프레임 업로드 서비스 사용
        response = await _frameUploadService.uploadFrame(
            _controller.image!, _selectedFrame!);

        // 프레임 업로드 성공 후 프레임 목록 새로고침
        await _refreshFrameList();
      } else {
        // 프레임이 선택되지 않은 경우 일반 업로드 서비스 사용
        response = await _uploadService.uploadImage(_controller.image!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _refreshFrameList() async {
    try {
      await _frameListService.getFrames(3); // userId는 실제 사용자 ID로 변경 필요
      if (mounted) {
        setState(() {
          _selectedFrame = null;
        });
      }
    } catch (e) {
      print('프레임 목록 새로고침 실패: $e');
    }
  }

  void _handleFrameSelected(Photo frame, Map<String, dynamic> frameData) {
    setState(() {
      _selectedFrame = frame;
    });
  }

  @override
  void dispose() {
    // _frameUploadService.dispose();
    _frameListService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF313233),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFF313233),
        title: const Text('새 게시물'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          TextButton(
            onPressed: _controller.image != null
                ? () => _uploadImage(_controller.image!)
                : null,
            child: const Text(
              '업로드',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [_preview(), _toolbar(), _images()],
      ),
    );
  }

  Widget _preview() {
    return Container(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: _controller.image != null
          ? Image.file(
              _controller.image!,
              fit: BoxFit.cover,
            )
          : Container(),
    );
  }

  Widget _toolbar() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FrameSelectionWidget(
                onFrameSelected: (Photo? frame) {
                  setState(() {
                    _selectedFrame = frame;
                    print("Selected frame: ${frame?.photoId}"); // 디버깅용
                  });
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0.5),
            margin: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: Color(0xff808080),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const ImageIcon(
                AssetImage('lib/assets/common/camera.png'),
                size: 24.0,
                color: Colors.white,
              ),
              onPressed: () async {
                try {
                  await _controller.getImage(ImageSource.camera);
                  setState(() {});
                } catch (e) {
                  // 권한이 거부된 경우 에러 메시지를 표시할 수 있습니다
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _images() {
    if (_controller.isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
        ),
        itemCount: _controller.images.length,
        itemBuilder: (context, index) {
          final asset = _controller.images[index];
          return GestureDetector(
            onTap: () =>
                _controller.selectImage(asset).then((_) => setState(() {})),
            child: AssetEntityImage(
              asset,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(200),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
