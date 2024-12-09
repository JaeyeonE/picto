import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/widgets/screen_custom/profile/user_profile.dart';


class Feed extends StatefulWidget {
  final int initialPhotoIndex;
  final int? folderId;
  final String? userId;
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

  Widget _buildImageView(Photo photo) {
    if (photo.photoPath.isEmpty) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
            size: 48,
          ),
        ),
      );
    }

    try {
      // Base64 디코딩 시도
      List<String> parts = photo.photoPath.split(',');
      String base64Data = parts.length > 1 ? parts[1] : photo.photoPath;
      
      return Image.memory(
        base64Decode(base64Data),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey[400],
                size: 48,
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.grey[400],
            size: 48,
          ),
        ),
      );
    }
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
        // Profile and stats row
        Row(
          children: [
            // 프로필 이미지와 이름
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
                  // 사용자 정보를 Container로 감싸서 고정된 너비 제공
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
            // 좋아요 카운트
            Row(
              mainAxisSize: MainAxisSize.min, // 이 부분도 중요합니다
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 20),
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
        // 위치 정보가 있는 경우에만 표시
        if (photo.location != null && photo.location!.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min, // 이 부분도 중요합니다
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible( // Expanded 대신 Flexible 사용
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