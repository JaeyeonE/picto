//lib/widgets/button/search_tag_list.dart

import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';

class SearchTagList extends StatelessWidget {
  final Function(String) onTagSelected;
  final List<String> selectedTags;

  const SearchTagList({
    super.key,
    required this.onTagSelected,
    required this.selectedTags,
  });

  // 실제 태그 데이터
  static const List<String> allTags = [
    '강아지', '고양이', '다람쥐', '햄스터',
    '새', '곤충', '파충류', '해양생물',
    '물고기', '산', '바다', '호수/강',
    '들판', '숲', '하늘', 
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: allTags.map((tag) {
          final isSelected = selectedTags.contains(tag);
          return InkWell(
            onTap: () => onTagSelected(tag),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}