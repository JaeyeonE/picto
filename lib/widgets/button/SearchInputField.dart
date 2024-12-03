// /Users/jaeyeon/workzone/picto/lib/widgets/button/SearchInputField.dart
import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> selectedTags;
  final Function(LatLng, List<String>) onSearch;
  final LatLng defaultLocation;

  const SearchInputField({
    super.key,
    required this.controller,
    required this.selectedTags,
    required this.onSearch,
    required this.defaultLocation,
  });

  Future<void> _processSearch(BuildContext context, String searchText) async {
    // 검색어에서 태그와 장소를 분리
    List<String> tags = [];
    String location = '';
    
    List<String> words = searchText.split(' ');
    for (String word in words) {
      if (word.startsWith('#')) {
        tags.add(word.substring(1));
      } else if (word.trim().isNotEmpty) {
        location += '${word.trim()} ';
      }
    }

    location = location.trim();
    
    if (location.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(location);
        
        if (locations.isNotEmpty) {
          final locationLatLng = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          
          // 먼저 검색 콜백 실행
          onSearch(locationLatLng, tags);
          
          // MapScreen으로 직접 이동 (모든 스택을 제거하고 이동)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        print('장소 검색 오류: $e');
      }
    } else if (tags.isNotEmpty) {
      // 태그만 있는 경우도 동일하게 처리
      onSearch(defaultLocation, tags);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '장소, 태그, 사진을 검색하세요',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (value) => _processSearch(context, value),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _processSearch(context, controller.text),
            icon: const Icon(Icons.search),
            color: AppColors.textSecondary,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              '취소',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}