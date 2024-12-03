import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '/services/user_manager_service.dart';
import 'package:picto/views/upload/upload_manager.dart';
import 'package:picto/models/photo_manager/photo.dart';

class ImageUploadData {
  static const String validationUrl = 'http://10.0.2.2:8083/validate';
  static const String taggingUrl = 'http://10.0.2.2:8083/tag';

  late final UserManagerService _userManagerService;

  Future<String> uploadImage(File image, {bool sharedActive = true}) async {
    try {
      if (!await image.exists()) {
        print('Error: 사진이 존재하지 않습니다');
        return '업로드 실패';
      }

      final targetUrl = sharedActive ? validationUrl : taggingUrl;

      var request = http.MultipartRequest('POST', Uri.parse(targetUrl))
        ..headers['Content-Type'] = 'multipart/form-data';

      String fileName = image.path.split('/').last;

      var fileStream = await http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile('file', fileStream, length,
          filename: fileName, contentType: MediaType('image', 'jpeg'));
      request.files.add(multipartFile);

      try {
        final position = await UserDataService.getCurrentLocation();
        var userId = await _userManagerService.getUserId() ?? 1;

        Map<String, dynamic> imageData = {
          'userId': userId,
          'lat': position.latitude,
          'lng': position.longitude,
          'tag': 'a',
          'registerTime': DateTime.now().millisecondsSinceEpoch,
          'frameActive': false,
          'sharedActive': sharedActive,
        };

        request.fields['request'] = json.encode(imageData);
        print('전송할 데이터: ${request.fields['request']}'); //데이터 비었는지 확인용
      } catch (e) {
        print('위치 정보 획득 실패: $e');
        // 에러 발생해도 기본 데이터는 보내기
        Map<String, dynamic> imageData = {
          'userId': 1,
          'lat': 0.0,
          'lng': 0.0,
          'tag': 'a',
          'registerTime': DateTime.now().millisecondsSinceEpoch,
          'frameActive': false,
          'sharedActive': sharedActive,
        };
        request.fields['request'] = json.encode(imageData);
      }

      print('서버로 요청 전송 시작...');
      var streamedResponse = await request.send();
      print('서버 응답 상태 코드: ${streamedResponse.statusCode}');

      var response = await http.Response.fromStream(streamedResponse);
      print('서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return '이미지 업로드 성공: ${responseData['tag'] ?? "태그 없음"}';
      } else {
        var errorData = json.decode(response.body);
        print('서버 에러 응답: $errorData');
        return '업로드 실패: ${errorData['error']}';
      }
    } catch (e) {
      print('예외 발생: $e');
      return '업로드 실패: $e';
    }
  }
}
