import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/models/common/photo.dart';
import 'package:picto/widgets/screen_custom/folder/folder_header.dart';

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
            return _buildPhotoItem(viewModel.photos[index]);
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

  Widget _buildPhotoItem(Photo photo) {
    return InkWell(
      onTap: () async {
        // 사진 상세 화면
      },
      onLongPress: () => _showPhotoOptions(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image:DecorationImage(
            image:NetworkImage(photo.photoUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            if(photo.location != null)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  photo.location!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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