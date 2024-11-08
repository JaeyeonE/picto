import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 폴더 아이콘
import 'package:picto/viewmodles/folder_view_model.dart';

class FolderListView extends StatefulWidget {
  const FolderListView({super.key});

  @override
  State<FolderListView> createState() => _FolderListViewState();
}

class _FolderListViewState extends State<FolderListView> {
  @override
  void initState() {
    super.initState(); // 폴더 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FolderViewModel>().loadFolders();
    });
  }

  @override
  Widget build(BuildContext context){
     return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: viewModel.isLoading ? 12 : viewModel.folderModel.folderList?.length ?? 0,
          itemBuilder: (context, index) {
            if (viewModel.isLoading) {
              return _buildEmptyFolder();
            }
            return _buildFolder(viewModel.folderModel.folderList![index]);
          },
        );
      },
    );
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
          Icon(Icons.folder, size: 40, color: Colors.grey[300]), // 나중에 폴더 아이콘으로 바꾸기
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

  Widget _buildFolder(String folderName){
    return Container(
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
          Text(
            folderName,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


