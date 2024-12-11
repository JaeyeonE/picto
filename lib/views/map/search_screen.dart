// /Users/jaeyeon/workzone/picto/lib/views/map/search_screen.dart
import 'package:flutter/material.dart';
import 'package:picto/services/user_manager_service.dart';
import 'package:picto/utils/app_color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/button/SearchInputField.dart';
import '../../widgets/button/search_tag_list.dart';

class SearchScreen extends StatefulWidget {
  final Function(LatLng, List<String>) onSearch;
  final LatLng defaultLocation;

  const SearchScreen({
    super.key,
    required this.onSearch,
    required this.defaultLocation,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedTags = [];
  final UserManagerService _userManagerService = UserManagerService();

  @override
  void initState() {
    super.initState();
    _loadUserFilters();
  }

  Future<void> _loadUserFilters() async {
    try {
      final filters = await _userManagerService.getSearchFilters();
      if (filters.isNotEmpty) {
        setState(() {
          selectedTags.addAll(filters);
          _updateSearchControllerText();
        });
      }
    } catch (e) {
      debugPrint('Failed to load filters: $e');
    }
  }

  void _updateSearchControllerText() {
    _searchController.text = selectedTags.map((e) => "#$e").join(" ") + " ";
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
  }

  void _addTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
      _updateSearchControllerText();
      _userManagerService.saveSearchFilters(selectedTags);
    });
  }

  void _clearTags() {
    setState(() {
      selectedTags = [
          '강아지', '고양이', '다람쥐', '햄스터', '새', '곤충', 
          '파충류', '해양생물', '물고기', '산', '바다', 
          '호수/강', '들판', '숲', '하늘'
        ];
      _searchController.clear();
      _userManagerService.saveSearchFilters([]);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SearchInputField(
              controller: _searchController,
              selectedTags: selectedTags,
              onSearch: widget.onSearch,
              defaultLocation: widget.defaultLocation,
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "검색 필터를 선택하세요",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedTags.clear();
                                _searchController.clear();
                              });
                            },
                            child: TextButton(
                              onPressed:
                                  _clearTags, // 직접 setState 호출 대신 _clearTags 메서드 사용
                              child: Text(
                                "전체해제",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SearchTagList(
                      onTagSelected: _addTag,
                      selectedTags: selectedTags,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
