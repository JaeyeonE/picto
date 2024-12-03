import 'package:http/http.dart' as http;
import 'package:picto/models/photo_manager/photo.dart';
import 'dart:convert';

class FrameService {
  static const String baseUrl = 'http://10.0.2.2:8083/validate';

  Future<List<String>> getUserFrames(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/frames?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List jsonList = json.decode(response.body);
        List<String> frames = jsonList
            .map((json) => Photo.fromJson(json).tag)
            .whereType<String>()
            .toList();

        return frames.take(5).toList();
      } else {
        throw Exception('액자 로드 실패');
      }
    } catch (e) {
      throw Exception('액자 가져오기 실패: $e');
    }
  }
}
