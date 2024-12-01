import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'upload_manager.dart';
import 'package:picto/services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final UploadController _controller = UploadController();
  final ImageUploadData _uploadService = ImageUploadData();

  @override
  void initState() {
    super.initState();
    _controller.loadPhotos().then((_) => setState(() {}));
  }

  Future<void> _uploadImage(File file) async {
    if (_controller.image == null) return;

    try {
      final response = await _uploadService.uploadImage(_controller.image!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            '내 앨범',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
            icon: const Icon(Icons.camera),
            onPressed: () async {
              if (await _controller.checkCameraPermission()) {
                _controller
                    .getImage(ImageSource.camera)
                    .then((_) => setState(() {}));
              } else {
                await PhotoManager.openSetting();
              }
            },
          ),
        ),
      ],
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
