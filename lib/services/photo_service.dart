// // lib/services/photo_service.dart

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import '../models/photo_manager/photo.dart';

// class PhotoService {
//   static const String baseUrl = 'http://3.35.153.213:8080';
//   final Dio _dio;

//   PhotoService() : _dio = Dio() {
//     _dio.options.headers = {
//       'Content-Type': 'application/json',
//     };
//   }

//   // 주변 사진 조회
//   Future<List<Photo>> getPhotosAround(int senderId) async {
//     debugPrint('주변 사진 요청 시작 - senderId: $senderId');
//     try {
//       final response = await _dio.get(
//         '$baseUrl/photo-manager/photos/around',
//         data: {'senderId': senderId}
//       );

//       debugPrint('응답 받음 - statusCode: ${response.statusCode}');
//       debugPrint('응답 데이터: ${response.data}');

//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data as List;
//         return data.map((json) => Photo.fromJson(json)).toList();
//       }
//       throw Exception('Failed to load nearby photos');
//     } catch (e) {
//       debugPrint('주변 사진 로드 에러: $e');
//       rethrow;
//     }
//   }

//   // 대표 사진 조회
//   Future<List<Photo>> getRepresentativePhotos({
//     String? eventType,
//     String? locationType,
//     String? locationName,
//     required int count,
//   }) async {
//     try {
//       final response = await _dio.get(
//         '$baseUrl/photo-manager/photos/representative',
//         data: {
//           if (eventType != null) 'eventType': eventType,
//           if (locationType != null) 'locationType': locationType,
//           if (locationName != null) 'locationName': locationName,
//           'count': count,
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data as List;
//         return data.map((json) => Photo.fromJson(json)).toList();
//       }
//       throw Exception('Failed to load representative photos');
//     } catch (e) {
//       print('Error getting representative photos: $e');
//       rethrow;
//     }
//   }

// //  사용자의 모든 사진 조회 << 수정할 것
//   Future<List<Photo>> getUserPhotos(int userId) async {
//     try {
//       final response = await _dio.get('$baseUrl/photo-store/photos/$userId');

//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data as List;
//         return data.map((json) => Photo.fromJson(json)).toList();
//       }
//       throw Exception('Failed to load user photos');
//     } catch (e) {
//       print('Error getting user photos: $e');
//       rethrow;
//     }
//   }

//   // 특정 사진 조회
//   Future<Photo> getPhotoDetail(int photoId, int userId) async {
//     try {
//       final response = await _dio.get('$baseUrl/photo-store/photos/$photoId/$userId');

//       if (response.statusCode == 200) {
//         return Photo.fromJson(response.data);
//       }
//       throw Exception('Failed to load photo detail');
//     } catch (e) {
//       print('Error getting photo detail: $e');
//       rethrow;
//     }
//   }

//   // 사진 삭제
//   Future<void> deletePhoto(int photoId, int userId) async {
//     try {
//       final response = await _dio.delete(
//         '$baseUrl/photo-store/photos/$photoId',
//         queryParameters: {'userId': userId},
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to delete photo');
//       }
//     } catch (e) {
//       print('Error deleting photo: $e');
//       rethrow;
//     }
//   }
// }