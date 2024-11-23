import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'photo_list.dart';

class FolderList extends StatefulWidget {
  const FolderList({super.key});

  @override
  State<FolderList> createState() => _FolderListState();
}

class _FolderListState extends State<FolderList> {
  final FolderViewModel viewModel = Get.find<FolderViewModel>();

  @override
  void initState() {
    super.initState();
    // 폴더 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: viewModel.isLoading ? 12 : viewModel.folders.length,
        itemBuilder: (context, index) {
          if (viewModel.isLoading) {
            return _buildEmptyFolder();
          }
          return _buildFolder(viewModel.folders[index]);
        },
      );
    });
  }

  Widget _buildEmptyFolder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolder(FolderModel folder) {
    return InkWell(
      onTap: () {
        // 폴더 선택 시 상태 업데이트
        viewModel.toggleFirst();
        viewModel.setCurrentFolder(folder.name, folder.folderId);
        
        // 해당 폴더의 사진 목록 로드
        viewModel.loadPhotos(folder.folderId);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoListWidget(folderId: folder.folderId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (folder.content != null && folder.content!.isNotEmpty)
                    Text(
                      folder.content!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}