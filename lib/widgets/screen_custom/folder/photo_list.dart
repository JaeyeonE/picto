import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/models/common/photo.dart';
import 'package:picto/widgets/screen_custom/folder/folder_header.dart';

class PhotoListWidget extends StatefulWidget {
  final String folderName; // 파라미터로 받음

  const PhotoListWidget({
    Key? key,
    required this.folderName,
  }) : super(key: key);

  @override
  State<PhotoListWidget> createState() => _PhotoListWidgetState();
}

class _PhotoListWidgetState extends State<PhotoListWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<FolderViewModel>().loadPhotos(widget.folderName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FolderHeader(
        onBackPressed: (){
          Navigator.pop(context);
        },
      ),
      
      body: Consumer<FolderViewModel>(
        builder: (context, viewModel, child){
          if (viewModel.isLoading) { // 로딩중일 때
            return const Center(
              child: CircularProgressIndicator(), // 로딩 아이콘
            );
          }

          if (viewModel.photos.isEmpty) {// 사진이 없을때
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey[400]
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 사진이 없습니다.',
                    style: TextStyle(
                      color:Colors.grey[600],
                      fontSize: 16,
                    ),
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
            }
          );
        }

      )
    );
  }

  Widget _buildPhotoItem(Photo photo) {
    return InkWell(
      onTap: () {
        // 사진 상세화면으로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image:DecorationImage(
            image:NetworkImage(photo.photo),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}