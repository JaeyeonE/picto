//lib/widgets/common/actual_tag_list.dart

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:picto/utils/app_color.dart';

class TagSelector extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsSelected;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsSelected,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> with SingleTickerProviderStateMixin {
  final List<String> baseTags = const ['전체', '순서', '폴더', '시간', '#강아지_사진대회'];
  String? expandedTag;
  DateTime? selectedDateTime;

  final Map<String, List<FilterOption>> filterOptions = {
    '순서': [
      FilterOption('좋아요순', false),
      FilterOption('최근순', false),
      FilterOption('조회순', false),
      FilterOption('최근 업로드순', false),
    ],
    '폴더': [ // 폴더 이름 따로 받아와서 생성하기.. 가능? 야옹 // 확인사항 뒤에 야옹 붙여둠
      FilterOption('폴더1', false),
      FilterOption('폴더2', false),
      FilterOption('폴더3', false),
    ],
  };

  void _resetToDefault() {
    setState(() {
      expandedTag = null;
      selectedDateTime = null;
      for (var options in filterOptions.values) {
        for (var option in options) {
          option.isSelected = false;
        }
      }
    });
    widget.onTagsSelected(['전체']);
  }

  void _handleSpecialTag() {
    List<String> newSelectedTags = List.from(widget.selectedTags);
    if (newSelectedTags.contains('#강아지_사진대회')) {
      newSelectedTags.remove('#강아지_사진대회');
    } else {
      newSelectedTags = ['#강아지_사진대회'];
    }
    widget.onTagsSelected(newSelectedTags);
  }

  Future<void> _showDropdownDialog(BuildContext context, String tag) async {
    final options = filterOptions[tag]!;
    
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ...options.map((option) => 
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _handleOptionSelect(option, tag);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: option.isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              option.title,
                              style: TextStyle(
                                fontSize: 14,
                                color: option.isSelected ? AppColors.primary : Colors.black87,
                                fontWeight: option.isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).toList(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
    );
  }

  void _toggleExpand(BuildContext context, String tag) {
    if (tag == '전체') {
      _resetToDefault();
      return;
    }
    if (tag == '#강아지_사진대회') {
      _handleSpecialTag();
      return;
    }
    if (tag == '시간') {
      _selectDateTime(context);
      return;
    }

    _showDropdownDialog(context, tag);
  }

  void _handleOptionSelect(FilterOption option, String category) {
    setState(() {
      List<String> newSelectedTags = List.from(widget.selectedTags);
      
      if (newSelectedTags.contains('전체')) {
        newSelectedTags.clear();
      }

      // 같은 카테고리의 다른 옵션들 선택 해제
      filterOptions[category]!.forEach((opt) {
        if (opt != option) opt.isSelected = false;
      });

      option.isSelected = !option.isSelected;

      // 선택된 태그 업데이트
      newSelectedTags.removeWhere((tag) => 
        filterOptions[category]!.any((opt) => opt.title == tag)
      );
      
      if (option.isSelected) {
        newSelectedTags.add(option.title);
      }

      widget.onTagsSelected(newSelectedTags);
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (picked != null) {
      setState(() {
        selectedDateTime = picked;
        List<String> newSelectedTags = List.from(widget.selectedTags);
        if (newSelectedTags.contains('전체')) {
          newSelectedTags.clear();
        }
        newSelectedTags.remove('시간');
        newSelectedTags.add('시간');
        widget.onTagsSelected(newSelectedTags);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: baseTags.length,
        itemBuilder: (context, index) {
          final tag = baseTags[index];
          final isSelected = widget.selectedTags.contains(tag) ||
              (filterOptions[tag]?.any((opt) => widget.selectedTags.contains(opt.title)) ?? false);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _toggleExpand(context, tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black87,
                        ),
                      ),
                      if (filterOptions.containsKey(tag))
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                        ),
                    ],
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

class FilterOption {
  final String title;
  bool isSelected;

  FilterOption(this.title, this.isSelected);
}