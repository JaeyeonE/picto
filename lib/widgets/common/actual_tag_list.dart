import 'package:flutter/material.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/utils/app_color.dart';

class TagSelector extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsSelected;
  final Function(String, String, int, int)? onFilterUpdate;
  final List<String> folderNames;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsSelected,
    this.onFilterUpdate,
    this.folderNames = const [],
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> with SingleTickerProviderStateMixin {
  final List<String> baseTags = const ['전체', '순서', '폴더', '시간', '#강아지_사진대회'];
  String? expandedTag;

  late Map<String, List<FilterOption>> filterOptions;

  @override
  void initState() {
    super.initState();
    _initializeFilterOptions();
  }

  @override
  void didUpdateWidget(TagSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.folderNames != widget.folderNames) {
      _initializeFilterOptions();
    }
  }

  void _initializeFilterOptions() {
    filterOptions = {
      '순서': [
        FilterOption('좋아요순', true),
        FilterOption('조회순', false),
      ],
      '시간': [
        FilterOption('하루', false),
        FilterOption('일주일', false),
        FilterOption('한달', true),
        FilterOption('일년', false),
        FilterOption('전체', false),
      ],
      '폴더': widget.folderNames.map((name) => FilterOption(name, false)).toList(),
    };
  }

  int _getStartDatetime(String period) {
    final now = DateTime.now();
    switch (period) {
      case '하루':
        return now.subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      case '일주일':
        return now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;
      case '한달':
        return now.subtract(const Duration(days: 30)).millisecondsSinceEpoch;
      case '일년':
        return now.subtract(const Duration(days: 365)).millisecondsSinceEpoch;
      case '전체':
        return 0;
      default:
        return now.subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    }
  }

  void _resetToDefault() {
    setState(() {
      expandedTag = null;
      for (var options in filterOptions.values) {
        for (var option in options) {
          option.isSelected = false;
        }
      }
    });
    widget.onTagsSelected(['전체']);
    
    if (widget.onFilterUpdate != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      widget.onFilterUpdate!('좋아요순', '전체', 0, now);
    }
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

    _showDropdownDialog(context, tag);
  }

  void _handleOptionSelect(FilterOption option, String category) {
    setState(() {
      List<String> newSelectedTags = List.from(widget.selectedTags);
      
      if (newSelectedTags.contains('전체')) {
        newSelectedTags.clear();
      }

      filterOptions[category]!.forEach((opt) {
        if (opt != option) opt.isSelected = false;
      });

      option.isSelected = !option.isSelected;

      newSelectedTags.removeWhere((tag) => 
        filterOptions[category]!.any((opt) => opt.title == tag)
      );
      
      if (option.isSelected) {
        newSelectedTags.add(option.title);
        
        if (widget.onFilterUpdate != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          
          if (category == '순서') {
            String currentPeriod = '전체';
            for (var timeOption in filterOptions['시간']!) {
              if (timeOption.isSelected) {
                currentPeriod = timeOption.title;
                break;
              }
            }
            widget.onFilterUpdate!(
              option.title,
              currentPeriod,
              _getStartDatetime(currentPeriod),
              now
            );
          } else if (category == '시간') {
            String currentSort = '좋아요순';
            for (var sortOption in filterOptions['순서']!) {
              if (sortOption.isSelected) {
                currentSort = sortOption.title;
                break;
              }
            }
            widget.onFilterUpdate!(
              currentSort,
              option.title,
              _getStartDatetime(option.title),
              now
            );
          }
        }
      }

      widget.onTagsSelected(newSelectedTags);
    });
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