import 'dart:io';
import 'package:dio/dio.dart';

class FrameUploadService {
  final Dio dio;

  FrameUploadService() : dio = Dio() {
    dio.options.baseUrl = 'http://10.0.2.2:8083/vaildate'; // 서버 주소 설정
  }

  Future<String> uploadImage(File file, int photoId) async {
    try {
      print('\n====== 프레임 이미지 업로드 시작 ======');
      print('photoId: $photoId');
      print('파일 경로: ${file.path}');

      final requestData = {
        'tag': ' ',
        'registerTime': DateTime.now().millisecondsSinceEpoch,
        'frameActive': false,
        'sharedActive': true,
      };

      print('\n====== 요청 데이터 ======');
      print('Request Data: $requestData');

      print('\n====== 요청 정보 ======');
      print('URL: ${dio.options.baseUrl}/photo-store/photos/frame/$photoId');
      print('Method: PATCH');
      print('Headers: Content-Type: multipart/form-data');
      print('데이터 구조:');
      print('- file: MultipartFile');
      print('- request: $requestData');

      final response = await dio.patch(
        '/photo-store/photos/frame/$photoId',
        data: {
          'file': await MultipartFile.fromFile(file.path),
          'request': requestData,
        },
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          responseType: ResponseType.json,
        ),
      );

      print('\n====== 응답 정보 ======');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('\n이미지 업로드 성공!');
        return '이미지가 성공적으로 업로드되었습니다.';
      } else {
        print('\n====== 응답 에러 발생 ======');
        print('Status Code: ${response.statusCode}');
        print('Response Data: ${response.data}');
        throw DioException(
          requestOptions:
              RequestOptions(path: '/photo-store/photos/frame/$photoId'),
          response: response,
          error: '이미지 업로드 실패: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('\n====== Dio 에러 상세 ======');
      print('에러 타입: ${e.type}');
      print('에러 메시지: ${e.message}');
      print('요청 URL: ${e.requestOptions.uri}');
      print('요청 메소드: ${e.requestOptions.method}');
      print('요청 헤더: ${e.requestOptions.headers}');
      print('요청 데이터: ${e.requestOptions.data}');

      if (e.response != null) {
        print('\n====== 에러 응답 상세 ======');
        print('응답 상태 코드: ${e.response?.statusCode}');
        print('응답 데이터: ${e.response?.data}');
        print('응답 헤더: ${e.response?.headers}');
      }

      throw Exception('이미지 업로드 실패: ${e.message}');
    } catch (e, stackTrace) {
      print('\n====== 일반 에러 상세 ======');
      print('에러 타입: ${e.runtimeType}');
      print('에러 메시지: $e');
      print('스택 트레이스:\n$stackTrace');
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  void dispose() {
    print('\n====== FrameUploadService 종료 ======');
    dio.close(); // Dio 인스턴스 정리
  }
}
