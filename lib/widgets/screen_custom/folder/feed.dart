import 'package:flutter/material.dart';
import 'package:picto/services/photo_manager_service.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/widgets/screen_custom/profile/user_profile.dart';


class Feed extends StatefulWidget {
  final int initialPhotoIndex;
  final int? folderId;
  final int? userId;
  final int photoId;

  const Feed({
    Key? key,
    required this.initialPhotoIndex,
    this.folderId,
    this.userId,
    required this.photoId,
  }) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  late PageController _pageController;
  int currentIndex = 0;
  final Map<int, bool> _likedStatus = {};

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialPhotoIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 실제 이미지 바이너리 데이터 사용 - Base64가 아닌 Uint8List 사용
  Widget _buildImageView(Photo photo) {
    if (photo.isLoading) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (photo.errorMessage != null) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.grey[400],
                size: 48,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  photo.errorMessage!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (photo.imageData != null) {
      return Image.memory(
        photo.imageData!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '이미지를 표시할 수 없습니다',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              '이미지를 찾을 수 없습니다',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final viewModel = context.read<FolderViewModel>();
    final bool isFolderView = widget.folderId != null;
    final bool isCurrentUser = widget.userId == viewModel.user.userId.toString();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFolderView || isCurrentUser)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정하기'),
              onTap: () => Navigator.pop(context),
            ),
          if (isFolderView || isCurrentUser)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('삭제하기'),
              onTap: () {
                Navigator.pop(context);
                if (isFolderView) {
                  viewModel.deletePhoto(widget.folderId, widget.photoId).then((_) {
                    Navigator.pop(context); // Feed 화면 닫기
                  });
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.visibility_off),
            title: const Text('숨기기'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('차단하기'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('게시물 신고하기'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<FolderViewModel>(
        builder: (context, viewModel, child) {
          final photos = viewModel.photos;
          
          if (photos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // 사진 PageView
              GestureDetector(
                onTapUp: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final tapPosition = details.globalPosition.dx;
                  
                  if (tapPosition < screenWidth * 0.25) {
                    // 왼쪽 1/4 터치
                    if (currentIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (tapPosition > screenWidth * 0.75) {
                    // 오른쪽 1/4 터치
                    if (currentIndex < photos.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return Center(
                      child: _buildImageView(photo),
                    );
                  },
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // Top bar with kebab menu
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(
                    LucideIcons.moreVertical,
                    color: Colors.white,
                  ),
                  onPressed: () => _showOptionsMenu(context),
                ),
              ),
              
              // Bottom info bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomInfo(context, photos[currentIndex], viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleLike(BuildContext context, Photo photo) async {
    final photoManagerService = Provider.of<PhotoManagerService>(context, listen: false);
    final viewModel = Provider.of<FolderViewModel>(context, listen: false);
    
    try {
      setState(() {
        _likedStatus[photo.photoId] = !(_likedStatus[photo.photoId] ?? false);
      });

      if (_likedStatus[photo.photoId] ?? false) {
        // 좋아요 추가
        await photoManagerService.likePhoto(viewModel.user.userId, photo.photoId);
      } else {
        // 좋아요 취소
        await photoManagerService.unlikePhoto(viewModel.user.userId, photo.photoId);
      }
    } catch (e) {
      // 에러 발생 시 상태 되돌리기
      setState(() {
        _likedStatus[photo.photoId] = !(_likedStatus[photo.photoId] ?? false);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('좋아요 처리 중 오류가 발생했습니다: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildBottomInfo(BuildContext context, Photo photo, FolderViewModel viewModel) {
    final user = viewModel.user;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfile(user: user),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: user?.profilePath != null 
                        ? NetworkImage(user!.profilePath!)
                        : null,
                      child: user?.profilePath == null 
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${user?.accountName ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.name ?? '',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 좋아요 버튼과 카운트
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _toggleLike(context, photo),
                    child: Icon(
                      _likedStatus[photo.photoId] ?? false
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _likedStatus[photo.photoId] ?? false
                          ? Colors.red
                          : Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${photo.likes}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (photo.location != null && photo.location!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    photo.location ?? '위치정보 없음',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}