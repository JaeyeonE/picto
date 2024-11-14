import 'package:dio/dio.dart';

import 'package:picto/models/common/user.dart';
import 'package:picto/models/common/photo.dart';

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

  Future<List<String>> getPhotos(String folderName) async {
    try {
      final response = await _dio.get('your_api_endpoint/folders/$folderName');
      return List<String>.from(response.data['folderList']);
    } catch (e) {
      print('Error in getFolders: $e');
      return [];
    }
  }

  Future<List<Photo>> getPhotosTest(String folderName) async {
    return [
      Photo(
        user: User(
          userName: "user1",
          userId: "test123",
          userBio: "test bio",
          userProfile: "assets/testimage/profile1.jpg",
          title: "Photographer",
          isPrivate: false,
        ),
        photo: "assets/testimage/water.jpg",
        description: "test explanation",
        likes: 20,
      ),
      Photo(
        user: User(
          userName: "user2",
          userId: "test1233",
          userBio: "test bio2",
          userProfile: "assets/testimage/proflie2.jpg",
          title: "Photographer2",
          isPrivate: false,
        ),
        photo: "assets/testimage/sunscreen.jpg",
        description: "test explanation2",
        likes: 30,
      )
    ];
  }
}