// /Users/jaeyeon/workzone/picto/lib/widgets/button/SearchInputField.dart
import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';
import 'package:dio/dio.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class SearchInputField extends StatelessWidget {
 final TextEditingController controller;
 final List<String> selectedTags;
 final Function(LatLng, List<String>) onSearch;  // 콜백 함수 수정
 final String kakaoRestApiKey = "1a34da63eca983b0798f77b2db5242fc";
 final LatLng defaultLocation;


 const SearchInputField({
   super.key,
   required this.controller,
   required this.selectedTags,
   required this.onSearch,
   required this.defaultLocation,
 });

 void _processSearch(String searchText) async {
   // 검색어에서 태그와 장소를 분리
   List<String> tags = [];
   String location = '';
   
   List<String> words = searchText.split(' ');
   for (String word in words) {
     if (word.startsWith('#')) {
       // '#' 제거 후 태그 리스트에 추가
       tags.add(word.substring(1));
     } else if (word.trim().isNotEmpty) {
       // 태그가 아닌 텍스트는 장소로 처리
       location += '${word.trim()} ';
     }
   }

   location = location.trim();
   
   if (location.isNotEmpty) {
     // 장소가 있는 경우 카카오 로컬 API로 검색
     final dio = Dio();
     try {
       final response = await dio.get(
         'https://dapi.kakao.com/v2/local/search/keyword.json',
         queryParameters: {'query': location},
         options: Options(
           headers: {
             'Authorization': 'KakaoAK $kakaoRestApiKey',
           },
         ),
       );

       if (response.statusCode == 200 && response.data['documents'].length > 0) {
         final document = response.data['documents'][0];
         final locationLatLng = LatLng(
           double.parse(document['y']),
           double.parse(document['x']),
         );
         onSearch(locationLatLng, tags);  // 위치와 태그 정보 전달
       }
     } catch (e) {
       print('장소 검색 오류: $e');
     }
   } else if (tags.isNotEmpty) {
  // 장소 없이 태그만 있는 경우
    onSearch(defaultLocation, tags); 
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
               onSubmitted: _processSearch,
             ),
           ),
         ),
         const SizedBox(width: 12),
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