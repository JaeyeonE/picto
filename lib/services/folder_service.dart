import 'package:dio/dio.dart';

class FolderService {
  final Dio _dio = Dio();
  
  Future<List<String>> getFolders() async {
    try {
      // API 엔드포인트는 실제 사용하는 주소로 변경해주세요
      final response = await _dio.get('your_api_endpoint/folders');
      return List<String>.from(response.data['folderList']);
    } catch (e) {
      print('Error in getFolders: $e');
      return [];
    }
  }

  Future<List<String>> getFoldersTest() async {
    // 테스트용 딜레이 (실제 API 호출처럼 보이게)
    await Future.delayed(const Duration(seconds: 1));
    
    // 테스트 데이터
    return [
      'PICTO',
      '기록연월',
      '2023 크리스마스',
      '가족여행',
      '친구들',
      '맛집',
      '운동',
      '독서',
      '영화'
    ];
  }

  Future<List<String>> getPhotos() async {
    try {
      final response = await _dio.get('your_api_endpoint/folders');
      return List<String>.from(response.data['folderList']);
    } catch (e) {
      print('Error in getFolders: $e');
      return [];
    }
  }
}