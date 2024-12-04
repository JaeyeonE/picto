// import 'dart:io';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'dart:convert';
// import 'package:mime/mime.dart';
// import '/services/user_manager_service.dart';
// import 'package:picto/services/location_service.dart';

// class ImageUploadData {
//   static const String validationUrl = 'http://10.0.2.2:8083/validate';
//   static const String taggingUrl = 'http://10.0.2.2:8083/tag';

//   late final UserManagerService _userManagerService;

//   Future<String> uploadImage(File image,
//       {bool sharedActive = true, bool frameActive = false}) async {
//     try {
//       final targetUrl = sharedActive ? validationUrl : taggingUrl;
//       final locationService = LocationService();

//       var request = http.MultipartRequest('POST', Uri.parse(targetUrl));
//       String? mimeType = lookupMimeType(image.path);

//       var multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         image.path,
//         contentType: mimeType != null ? MediaType.parse(mimeType) : null,
//       );
//       request.files.add(multipartFile);

//       try {
//         var userId = await _userManagerService.getUserId() ?? 1;
//         Position? position = await locationService.getCurrentLocation();
//         bool isEnabled = await locationService.isLocationEnabled();
//         if (frameActive) print(isEnabled);

//         Map<String, dynamic> imageData = {
//           'userId': userId,
//           'lat': position?.latitude,
//           'lng': position?.longitude,
//           'tag': 'a',
//           'registerTime': DateTime.now().millisecondsSinceEpoch,
//           'frameActive': frameActive,
//           'sharedActive': sharedActive,
//         };

//         request.fields['request'] = json.encode(imageData);
//         print('전송할 데이터: ${request.fields['request']}');
//       } catch (e) {
//         print('위치 정보 획득 실패: $e');
//         Map<String, dynamic> imageData = {
//           'userId': 1,
//           'lat': 0.0,
//           'lng': 0.0,
//           'tag': 'a',
//           'registerTime': DateTime.now().millisecondsSinceEpoch,
//           'frameActive': frameActive,
//           'sharedActive': sharedActive,
//         };
//         request.fields['request'] = json.encode(imageData);
//       }

//       print('서버로 요청 전송 시작...');
//       var streamedResponse = await request.send();
//       print('서버 응답 상태 코드: ${streamedResponse.statusCode}');

//       var response = await http.Response.fromStream(streamedResponse);
//       print('서버 응답 내용: ${response.body}');

//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//         return '이미지 업로드 성공: ${responseData['tag'] ?? "태그 없음"}';
//       } else {
//         var errorData = json.decode(response.body);
//         print('서버 에러 응답: $errorData');
//         return '업로드 실패: ${errorData['error']}';
//       }
//     } catch (e) {
//       print('예외 발생: $e');
//       return '업로드 실패: $e';
//     }
//   }
// }
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:mime/mime.dart';
import '/services/user_manager_service.dart';
import 'package:picto/services/location_service.dart';

class ImageUploadData {
  // 실제 서버 URL로 변경
  static const String validationUrl = 'http://172.16.0.96:8083/validate';
  static const String taggingUrl = 'http://172.16.0.96:8083/tag';

  late final UserManagerService _userManagerService;

  Future<String> uploadImage(File image,
      {bool sharedActive = true, bool frameActive = false}) async {
    try {
      final targetUrl = sharedActive ? validationUrl : taggingUrl;
      final locationService = LocationService();

      var request = http.MultipartRequest('POST', Uri.parse(targetUrl));
      String? mimeType = lookupMimeType(image.path);

      // multipart/form-data 형식에 맞게 파일 추가
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      );
      request.files.add(multipartFile);

      try {
        var userId = await _userManagerService.getUserId() ?? 1;
        Position? position = await locationService.getCurrentLocation();

        // PhotoUploadRequest 형식에 맞게 데이터 구성
        Map<String, dynamic> imageData = {
          'userId': userId,
          'lat': position?.latitude ?? 0.0,
          'lng': position?.longitude ?? 0.0,
          'tag': '', // 서버에서 자동 생성됨
          'registerTime': DateTime.now().millisecondsSinceEpoch,
          'frameActive': frameActive,
          'sharedActive': sharedActive,
        };

        request.fields['request'] = json.encode(imageData);
        print('Request data: ${request.fields['request']}');
      } catch (e) {
        print('Location fetch failed: $e');
        Map<String, dynamic> imageData = {
          'userId': 100,
          'lat': 0.0,
          'lng': 0.0,
          'tag': '',
          'registerTime': DateTime.now().millisecondsSinceEpoch,
          'frameActive': frameActive,
          'sharedActive': sharedActive,
        };
        request.fields['request'] = json.encode(imageData);
      }

      print('Sending request to server...');
      var streamedResponse = await request.send();
      print('Server response code: ${streamedResponse.statusCode}');

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return 'Upload successful: ${responseData['tag'] ?? "No tag"}';
      } else {
        var errorData = json.decode(response.body);
        print('Server error response: $errorData');
        if (errorData['error'] == 'person') {
          return '사람이 포함된 이미지는 업로드할 수 없습니다.';
        } else if (errorData['error'] == 'nsfw') {
          return '부적절한 콘텐츠가 감지되었습니다.';
        } else if (errorData['error'] == 'text') {
          return '텍스트가 포함된 이미지는 업로드할 수 없습니다.';
        }
        return '업로드 실패: ${errorData['error']}';
      }
    } catch (e) {
      print('Exception: $e');
      return '업로드 실패: $e';
    }
  }
}
