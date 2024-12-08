import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/services/photo_store.dart';
import 'package:picto/services/user_manager_service.dart';

import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/models/folder/folder_model.dart';
import 'photo_list.dart';
import 'package:picto/views/folder/folder.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/services/folder_service.dart';

class FolderList extends StatefulWidget {
  final User user;
  const FolderList({super.key, required this.user});

  @override
  State<FolderList> createState() => _FolderListState();
}

class _FolderListState extends State<FolderList> {
  late final FolderViewModel viewModel;

  @override
  void initState() {
    super.initState();

    final dio = Dio();
    final folderService = FolderService(dio, userId: widget.user.userId);
    final photoStore = PhotoStoreService(baseUrl: 'http://52.78.237.242:8084');
    final userManager = UserManagerService();

    // 디버깅을 위한 print 추가
    print('User ID: ${widget.user.userId}');

    viewModel = FolderViewModel(
      user: widget.user,
      folderService: folderService,
      photoStoreService: photoStore,
      userManagerService: userManager,
    );

    // 로딩 상태 표시
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await viewModel.loadFolders();
        print('Folders loaded: ${viewModel.folders.length}');
      } catch (e) {
        print('Error loading folders: $e');
        // 에러 발생시 사용자에게 알림
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('폴더를 불러오는데 실패했습니다: $e')),
          );
        }
      }
    });
  }

  @override
Widget build(BuildContext context) {
  return ChangeNotifierProvider.value(
    value: viewModel,
    child: Builder(  // Builder 추가
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Folders'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Consumer<FolderViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.folders.isEmpty) {
              return const Center(
                child: Text('폴더가 없습니다.'),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: viewModel.folders.length,
              itemBuilder: (context, index) {
                return _buildFolder(context, viewModel.folders[index]);
              },
            );
          },
        ),
      ),
    ));
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

  Widget _buildFolder(BuildContext context, FolderModel folder) {
  return InkWell(
    onTap: () {
      if (folder.folderId != null) {
        // context를 미리 변수에 저장
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        
        viewModel.loadPhotos(folder.folderId).then((_) {
          viewModel.setCurrentFolder(folder.name, folder.folderId);
          viewModel.toggleFirst();
          
          // 저장된 context 사용
          navigator.push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: viewModel,
                child: Folder(folderId: folder.folderId!),
              ),
            ),
          );
        }).catchError((e) {
          print('Error loading photos: $e');
          // 저장된 scaffoldMessenger 사용
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('폴더를 열 수 없습니다: $e')),
          );
        });
      }
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
            child: Text(
              folder.name ?? 'No id',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
void dispose() {
  super.dispose();
}
}
