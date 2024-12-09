import 'package:flutter/material.dart';
import 'package:picto/widgets/screen_custom/folder/photo_list.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfile extends StatefulWidget {
  final User user;
  final bool isMyProfile;

  const UserProfile({
    Key? key,
    required this.user,
    this.isMyProfile = false,
  }) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late FolderViewModel viewModel;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FolderViewModel>(context, listen: false);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await viewModel.loadUserPhotos(widget.user.userId);
  }

  void _showBookmarkedUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('즐겨찾기한 사용자'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.userInfo?.marks.length ?? 0,
            itemBuilder: (context, index) {
              final user = viewModel.userInfo?.marks[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user?.profilePath != null 
                    ? NetworkImage(user!.profilePath!)
                    : null,
                  child: user?.profilePath == null 
                    ? const Icon(Icons.person)
                    : null,
                ),
                title: Text(user?.name ?? ''),
                subtitle: Text('@${user?.accountName ?? ''}'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(
                        user: user!,
                        isMyProfile: false,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('신고하기'),
            onTap: () {
              // 신고 기능 구현
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('차단하기'),
            onTap: () {
              // 차단 기능 구현
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _toggleBookmark() async {
    final sourceId = viewModel.user.userId;
    final targetId = widget.user.userId;

    try {
      if (isBookmarked) {
        await viewModel.userManagerService.removeBookmark(sourceId, targetId);
      } else {
        await viewModel.userManagerService.addBookmark(sourceId, targetId);
      }
      setState(() {
        isBookmarked = !isBookmarked;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          if (widget.isMyProfile)
            IconButton(
              icon: const Icon(Icons.bookmarks),
              onPressed: _showBookmarkedUsers,
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.moreVertical),
              onPressed: _showOptionsMenu,
            ),
        ],
      ),
      body: Consumer<FolderViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // 프로필 섹션
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.user.profilePath != null 
                        ? NetworkImage(widget.user.profilePath!)
                        : null,
                      child: widget.user.profilePath == null 
                        ? const Icon(Icons.person, size: 40)
                        : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '@${widget.user.accountName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!widget.isMyProfile)
                                IconButton(
                                  icon: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  ),
                                  onPressed: _toggleBookmark,
                                ),
                            ],
                          ),
                          Text(
                            widget.user.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.user.intro ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // 사진 목록
              Expanded(
                child: PhotoListWidget(
                  type: PhotoListType.user,
                  userId: widget.user.userId,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}