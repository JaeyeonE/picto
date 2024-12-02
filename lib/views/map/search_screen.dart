// /Users/jaeyeon/workzone/picto/lib/views/map/search_screen.dart
import 'package:flutter/material.dart';
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
  final List<String> selectedTags = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    setState(() {
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
        _searchController.text = selectedTags.map((e) => "#$e").join(" ") + " ";
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      }
    });
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
                            child: Text(
                              "전체해제",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
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