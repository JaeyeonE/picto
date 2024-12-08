import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:picto/utils/app_color.dart';
import 'package:picto/views/map/map.dart';
import 'package:picto/views/profile/logout.dart';
import 'package:picto/views/sign_in/login_screen.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/widgets/screen_custom/folder/folder_list.dart';
import 'package:picto/services/folder_service.dart';
import 'package:picto/services/photo_store.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final User currentUser;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.currentUser,
  });

  void _navigateToScreen(BuildContext context, int index) {
    Dio dio = Dio();
    if (index == 2 && ModalRoute.of(context)?.settings.name == '/map') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      Widget screen;
      switch (index) {
        case 0:
          screen = const LoginScreen(); // 설정 화면 -> 수정할것
          break;
        case 1:
          screen = const LoginScreen(); // 실시간 화면 -> 우선 로그인 화면으로 구현
          break;
        case 2:
          screen = MapScreen(initialUser: currentUser); // 지도 화면
          break;
        case 3:
          screen = ChangeNotifierProvider(
          create: (context) => FolderViewModel(
            user: currentUser,
            folderService: FolderService(dio, userId: currentUser.userId),
            photoStoreService: PhotoStoreService(baseUrl: 'http://52.78.237.242:8084'),
            userManagerService: UserManagerService(),
          ),
          child: Scaffold(
            body: FolderList(user: currentUser),
            bottomNavigationBar: CustomNavigationBar(
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
              currentUser: currentUser,
            ),
          ),
        );
          break;
        case 4:
          screen = const ProfileScreen(); // 로그아웃 버튼
          break;
        default:
          screen = const ProfileScreen(); // 로그아웃 버튼
          break;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, Icons.settings),
          _buildNavItem(context, 1, Icons.bar_chart),
          _buildMapButton(context),
          _buildNavItem(context, 3, Icons.folder_outlined),
          _buildNavItem(context, 4, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        onItemSelected(index);
        _navigateToScreen(context, index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onItemSelected(2);
        _navigateToScreen(context, 2);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.location_on_outlined,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}
