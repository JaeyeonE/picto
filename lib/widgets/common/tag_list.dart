import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';


class TagSelector extends StatelessWidget {
  final String selectedTag;
  final Function(String) onTagSelected;

  const TagSelector({
    super.key,
    required this.selectedTag,
    required this.onTagSelected,
  });

  final List<String> tags = const ['전체', '순서', '폴더', '시간', '#강아지_사진대회'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: AppColors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedTag == tag;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTagSelected(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.selectedTagBg : AppColors.unselectedTagBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    tag,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? AppColors.selectedTagText : AppColors.unselectedTagText,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}