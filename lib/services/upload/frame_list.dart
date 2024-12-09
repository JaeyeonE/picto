import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:picto/models/photo_manager/photo.dart';
import 'package:picto/services/location_service.dart';
import 'package:dio/dio.dart';

class FrameListService {
  static const String ListUrl =
      'http://52.78.237.242:8084/photo-store/photos/frames';
  final Dio _dio = Dio();
  Future<List<Photo>> getFrames(int? userId) async {
    try {
      print('\n====== 프레임 목록 조회 시작 ======');
      print('요청 URL: $ListUrl');

      final response = await _dio.get(
        ListUrl,
        queryParameters: {'userId': userId},
      );

      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));

      print('\n====== 서버 응답 상세 ======');
      print('Headers: ${response.headers}');
      print('Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        print('\n====== 응답 데이터 처리 시작 ======');

        final List<dynamic> jsonList = response.data as List<dynamic>;
        print('받은 데이터 개수: ${jsonList.length}');

        List<Photo> frames = [];

        for (var i = 0; i < jsonList.length; i++) {
          print('\n-- 프레임 데이터 처리 #$i --');
          try {
            print('원본 데이터: ${jsonList[i]}');

            Map<String, dynamic> frameData =
                Map<String, dynamic>.from(jsonList[i]);
            print('변환된 Map 데이터: $frameData');

            // API 응답의 모든 필드를 Photo 모델에 맞게 매핑
            Map<String, dynamic> photoData = {
              'photoId': frameData['photoId'],
              'userId': userId,
              'photoPath': frameData['photoPath'] ?? '',
              'lat': frameData['lat'],
              'lng': frameData['lng'],
              'location': frameData['location'],
              'tag': frameData['tag'] ?? '액자',
              'likes': frameData['likes'] ?? 0,
              'views': frameData['views'] ?? 0,
              'frameActive': true,
              'sharedActive': frameData['shareActive'] ?? false,
              'registerDatetime': frameData['uploadTime'] ??
                  DateTime.now().millisecondsSinceEpoch,
              'updateDatetime': frameData['uploadTime'] ??
                  DateTime.now().millisecondsSinceEpoch,
            };
            print('매핑된 Photo 데이터: $photoData');

            final photo = Photo.fromJson(photoData);
            print('생성된 Photo 객체: ${photo.toJson()}');

            frames.add(photo);
            print(frames);
            print('프레임 #$i 처리 완료');
          } catch (e, stackTrace) {
            print('\n!! 프레임 #$i 처리 중 오류 발생 !!');
            print('에러 타입: ${e.runtimeType}');
            print('에러 메시지: $e');
            print('스택 트레이스:\n$stackTrace');
            print('문제의 원본 데이터: ${jsonList[i]}');
          }
        }

        print('\n====== 처리 완료 요약 ======');
        print('총 받은 데이터 수: ${jsonList.length}');
        print('성공적으로 처리된 프레임 수: ${frames.length}');
        print('처리 완료 시간: ${DateTime.now()}');

        return frames;
      } else {
        print('\n!!!!! 서버 응답 실패 !!!!!');
        print('Status Code: ${response.statusCode}');
        print('Response Data: ${response.data}');
        print('Response Headers: ${response.headers}');

        throw DioException(
          requestOptions: RequestOptions(path: ListUrl),
          response: response,
          error: '프레임 목록 조회 실패: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('\n!!!!! Dio 에러 발생 !!!!!');
      print('에러 타입: ${e.type}');
      print('에러 메시지: ${e.message}');
      print('요청 URL: ${e.requestOptions.uri}');
      print('요청 메소드: ${e.requestOptions.method}');
      print('요청 헤더: ${e.requestOptions.headers}');
      print('요청 데이터: ${e.requestOptions.data}');
      print('요청 파라미터: ${e.requestOptions.queryParameters}');

      if (e.response != null) {
        print('응답 상태 코드: ${e.response?.statusCode}');
        print('응답 데이터: ${e.response?.data}');
        print('응답 헤더: ${e.response?.headers}');
      }

      return []; // UI 로딩 상태 해제를 위해 빈 배열 반환
    } catch (e, stackTrace) {
      print('\n!!!!! 일반 에러 발생 !!!!!');
      print('에러 타입: ${e.runtimeType}');
      print('에러 메시지: $e');
      print('스택 트레이스:\n$stackTrace');

      return []; // UI 로딩 상태 해제를 위해 빈 배열 반환
    }
  }

  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dio.close();
    });
  }
}
