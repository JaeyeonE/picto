import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/models/common/photo.dart';
import 'package:picto/widgets/screen_custom/folder/photo_detail.dart';

class PhotoListWidget extends StatefulWidget {
  final int? folderId; // 파라미터로 받음

  const PhotoListWidget({
    Key? key,
    this.folderId,
  }) : super(key: key);

  @override
  State<PhotoListWidget> createState() => _PhotoListWidgetState();
}

class _PhotoListWidgetState extends State<PhotoListWidget> {
  final FolderViewModel viewModel = Get.find<FolderViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      viewModel.loadPhotos(widget.folderId);
      viewModel.loadFolderUsers(widget.folderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(   
      body: Obx((){
        if (viewModel.photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'no photos',
                  style: TextStyle(
                    color: Color.fromARGB(255, 128, 128, 128),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24,),
                ElevatedButton.icon(
                  onPressed: () => _uploadPhoto(),
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('add photo'),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: viewModel.photos.length,
          itemBuilder: (context, index) {
            return _buildPhotoItem(viewModel.photos[index], index); // index 추가
          },
        );
      }),
      floatingActionButton: !viewModel.isLoading && viewModel.photos.isNotEmpty
        ? FloatingActionButton(
          onPressed: () => _uploadPhoto(),
          child: const Icon(Icons.add_photo_alternate),
        )
        : null,
    );
  }

  Widget _buildPhotoItem(Photo photo, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetail(
              initialPhotoIndex: index,
              folderId: widget.folderId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(photo.photoUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _uploadPhoto() async {
    // 업로드 구현 필요
  }

  void _showPhotoOptions(Photo photo) {
    showModalBottomSheet(
      context: context, 
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('delete'),
            onTap: () async {
              Navigator.pop(context);
              await viewModel.deletePhoto(widget.folderId, photo.photoId);
            },
          ),
          // other options with ListTile()
        ],
      ),
    );
  }

  
}