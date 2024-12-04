//lib/widgets/common/navigation.dart

import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';

import 'package:picto/views/map/map.dart';
import 'package:picto/views/sign_in/login_screen.dart';
// 이동할 페이지들의 import 구문 추가

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  void _navigateToScreen(BuildContext context, int index) {
    if (index == 2 && ModalRoute.of(context)?.settings.name == '/map') {
      // 현재 맵 화면에서 맵 버튼을 누른 경우 - 현재 위치로 이동하기 위한 처리
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      Widget screen;
      switch (index) {
        case 0:
          screen = const LoginScreen();  // 설정 화면 -> 수정할것
          break;
        case 1:
          screen = const LoginScreen();     // 실시간 화면 -> 우선 로그인 화면으로 구현
          break;
        case 2:
          screen = const MapScreen();  // 지도 화면
          break;
        case 3:
          screen = const LoginScreen();  // 폴더 화면 -> 수정할 것
          break;
        case 4:
          screen = const LoginScreen();  // 프로필 화면 -> 수정할 것
          break;
        default:
          screen = const LoginScreen();  // 기본값 설정
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