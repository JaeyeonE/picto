import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';

class PhotoResponse {
  final Uint8List imageData;
  final String contentType;

  PhotoResponse({required this.imageData, required this.contentType});
}



class PhotoStoreService {
  final String baseUrl;

  PhotoStoreService({required this.baseUrl});

  // 1. 사진 업로드 -> upload_store.dart에 있어요

  // 2. 액자 사진 업로드
  Future<Map<String, dynamic>> uploadFramePhoto({
    required int photoId,
    required File photoFile,
    required String tag,
    required int registerTime,
    required bool frameActive,
    required bool sharedActive,
  }) async {
    var uri = Uri.parse('$baseUrl/photo-store/photos/frame/$photoId');
    var request = http.MultipartRequest('PATCH', uri);

    // Add file
    var fileStream = http.ByteStream(photoFile.openRead());
    var length = await photoFile.length();
    var multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: photoFile.path.split('/').last,
    );
    request.files.add(multipartFile);

    // Add request data
    var requestData = {
      'tag': tag,
      'registerTime': registerTime,
      'frameActive': frameActive,
      'sharedActive': sharedActive,
    };

    request.fields['request'] = jsonEncode(requestData);

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    return jsonDecode(responseData);
  }

  // 3. 액자 목록 조회
  Future<List<dynamic>> getFrameList(int userId) async {
    final uri = Uri.parse('$baseUrl/photo-store/photos/frames')
        .replace(queryParameters: {'userId': userId.toString()});

    final response = await http.get(uri);
    return jsonDecode(response.body);
  }

  // 4. 사진 공유 상테 업데이트
  Future<void> updatePhotoShareStatus(int photoId, bool shared) async {
    final uri = Uri.parse('$baseUrl/photo-store/photos/$photoId/share')
        .replace(queryParameters: {'shared': shared.toString()});

    await http.patch(uri);
  }

  // 5. 사진 조회
  // Primary photo download function that returns both image data and content type
  // 5. 사진 조회
  Future<PhotoResponse> downloadPhoto(int photoId) async {
    try {
      final uri = Uri.parse('http://52.78.237.242:8084/photo-store/photos/download/$photoId');
      final response = await http.get(uri, headers: {
        'Accept': 'image/*',  // Accepting any image type
      });

      if (response.statusCode == 200) {
        // Get content type from headers to handle different image formats
        String contentType = response.headers['content-type'] ?? 'image/jpeg';

        // 바이트 단위 변환
        return PhotoResponse(
            imageData: response.bodyBytes,
            contentType: contentType
        );
      } else {
        print('Server response: ${response.statusCode} - ${response.body}');
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('download', e);
      rethrow;
    }
  }

  // photo response 순수 이미지 데이터만 반환
  Future<Uint8List> getPhotoBytes(int photoId) async {
    try {
      // 바이트 단위 변환
      final response = await downloadPhoto(photoId);
      return response.imageData;
    } catch (e) {
      _handleError('get photo bytes', e);
      rethrow;
    }
  }

  void _handleError(String operation, dynamic error) {
    print('$operation error: $error');
    throw Exception('Failed to $operation photo: $error');
  }

  // 6. 사진 삭제
  Future<void> deletePhoto(int photoId, int userId) async {
    final uri = Uri.parse('$baseUrl/photo-store/photos/$photoId')
        .replace(queryParameters: {'userId': userId.toString()});

    await http.delete(uri);
  }


  // 단순 이미지 바이너리 형태로 다운로드
  Future<Uint8List> downloadPhoto22(int photoId) async {
    final uri = Uri.parse('$baseUrl/photo-store/photos/download/$photoId');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      print('${response.bodyBytes}');
      return response.bodyBytes; // 바이너리 데이터로 반환
    } else {
      throw Exception('Failed to download photo');
    }
  }
}
