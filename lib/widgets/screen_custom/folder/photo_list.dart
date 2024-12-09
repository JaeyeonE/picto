import 'package:flutter/material.dart';
import 'package:picto/views/upload/upload.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/widgets/screen_custom/folder/feed.dart';

enum PhotoListType {
  folder,
  user,
}

class PhotoListWidget extends StatefulWidget {
  final PhotoListType type;
  final int? folderId;
  final String? userId;

  const PhotoListWidget({
    Key? key,
    required this.type,
    this.folderId,
    this.userId,
  }) : assert(
          (type == PhotoListType.folder && folderId != null) ||
          (type == PhotoListType.user && userId != null),
          'folderId must be provided for folder type, userId for user type',
        ),
        super(key: key);

  @override
  State<PhotoListWidget> createState() => _PhotoListWidgetState();
}

class _PhotoListWidgetState extends State<PhotoListWidget> {
  late FolderViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FolderViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhotos();
    });
  }

  void _loadPhotos() {
    switch (widget.type) {
      case PhotoListType.folder:
        viewModel.loadPhotos(widget.folderId!);
        viewModel.loadFolderUsers(widget.folderId);
        break;
      case PhotoListType.user:
        viewModel.loadUserPhotos(int.parse(widget.userId!));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(   
      body: Consumer<FolderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.photos.isEmpty) {
            return _buildEmptyState();
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
              return _buildPhotoItem(viewModel.photos[index], index);
            },
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEmptyState() {
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
            widget.type == PhotoListType.folder 
              ? '이 폴더에 사진이 없습니다'
              : '이 사용자의 사진이 없습니다',
            style: const TextStyle(
              color: Color.fromARGB(255, 128, 128, 128),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.type == PhotoListType.folder)
            ElevatedButton.icon(
              onPressed: () => _uploadPhoto(),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('사진 추가'),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading || viewModel.photos.isEmpty) {
          return const SizedBox.shrink();
        }

        // 폴더 뷰에서만 FAB 표시
        if (widget.type == PhotoListType.folder) {
          return FloatingActionButton(
            onPressed: () => _uploadPhoto(),
            child: const Icon(Icons.add_photo_alternate),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPhotoItem(Photo photo, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: viewModel,
              child: Feed(
                initialPhotoIndex: index,
                folderId: widget.type == PhotoListType.folder ? widget.folderId : null,
                userId: widget.userId,
                photoId: photo.photoId,
              ),
            ),
          ),
        );
      },
      onLongPress: widget.type == PhotoListType.folder 
        ? () => _showPhotoOptions(photo)
        : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(photo.photoPath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _uploadPhoto() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadScreen(),
      ),
    );
    
    // 업로드 화면에서 돌아왔을 때 사진 목록 새로고침
    if (result == true) {
      _loadPhotos();
    }
  }

  void _showPhotoOptions(Photo photo) {
    showModalBottomSheet(
      context: context, 
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('삭제'),
            onTap: () async {
              Navigator.pop(context);
              if (widget.type == PhotoListType.folder) {
                await viewModel.deletePhoto(widget.folderId, photo.photoId);
              }
            },
          ),
        ],
      ),
    );
  }
}