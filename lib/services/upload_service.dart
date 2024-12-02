import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:picto/views/upload/upload_manager.dart';

class ImageUploadData {
  static const String validationUrl = 'http://10.0.2.2:5000/validate';
  static const String taggingUrl = 'http://10.0.2.2:8083/tag';

  Future<String> uploadImage(File image, {bool sharedActive = true}) async {
    try {
      if (!await image.exists()) {
        print('Error: 파일이 존재하지 않습니다');
        return '업로드 실패: 파일이 존재하지 않습니다';
      }
      print('파일 경로: ${image.path}');

      final targetUrl = sharedActive ? validationUrl : taggingUrl;
      var request = http.MultipartRequest('POST', Uri.parse(targetUrl));

      var fileStream = await http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile('image', fileStream, length,
          filename: image.path.split('/').last);
      request.files.add(multipartFile);

      try {
        final position = await UserDataService.getCurrentLocation();
        print('위치 데이터 획득: ${position.latitude}, ${position.longitude}');

        final location =
            await UserDataService.getAddressFromCoordinates(position);
        print('주소 변환 결과: $location');

        Map<String, dynamic> imageData = {
          'userId': 'userid',
          'lat': position.latitude,
          'lng': position.longitude,
          'location': location,
          'registerTime': DateTime.now().millisecondsSinceEpoch,
          'frameActive': false,
          'sharedActive': sharedActive,
        };

        request.fields['data'] = json.encode(imageData);
        print('전송할 데이터: ${request.fields['data']}');
      } catch (e) {
        print('위치 데이터 획득 실패: $e');
      }

      print('서버로 요청 전송 시작...');
      request.headers['Content-Type'] = 'multipart/form-data';

      var streamedResponse = await request.send();
      print('서버 응답 상태 코드: ${streamedResponse.statusCode}');

      var response = await http.Response.fromStream(streamedResponse);
      print('서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return '이미지 업로드 성공: ${responseData['tags'] ?? "태그 없음"}';
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
