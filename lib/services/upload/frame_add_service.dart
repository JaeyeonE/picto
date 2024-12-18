import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:picto/services/location_service.dart';
import 'package:picto/services/user_manager_service.dart';

class FrameAddService {
  static const String AddUrl = 'http://52.78.237.242:8084/photo-store/photos';
  late final UserManagerService _userManagerService;

  FrameAddService({UserManagerService? userManagerService}) 
    : _userManagerService = userManagerService ?? UserManagerService();


  Future<Map<String, dynamic>> addFrame() async {
    final Dio dio = Dio();
    final position = await LocationService().getCurrentLocation();
    int? userId = await _userManagerService.getUserId();

    try {
      Map<String, dynamic> requestData = {
        'userId': userId,
        'lat': position.latitude,
        'lng': position.longitude,
        'registerTime': DateTime.now().millisecondsSinceEpoch,
        'frameActive': true,
      };

      final response = await dio.post(
        AddUrl,
        data: FormData.fromMap({
          'request': MultipartFile.fromString(
            jsonEncode(requestData),
            contentType: MediaType.parse('application/json'),
          ),
        }),
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/photo-store/photos'),
          response: response,
          error: '액자 추가 실패: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('Dio 에러 발생:');
      print('에러 타입: ${e.type}');
      print('에러 메시지: ${e.message}');
      print('응답: ${e.response?.data}');
      print('상태 코드: ${e.response?.statusCode}');
      print('요청 데이터: ${e.requestOptions.data}');
      throw Exception('액자 추가 실패: ${e.message}');
    } catch (e) {
      print('일반 에러 발생: $e');
      throw Exception('액자 추가 실패: $e');
    }
  }
}
