import 'dart:convert';
import 'package:http/http.dart' as http;

class PhotoService {
  final String _baseUrl = 'https://your-api-url.com';

  Future<void> uploadPhoto(String userId, String photoPath, double lat,
      double lng, String location) async {
    final url = Uri.parse('$_baseUrl/photo-store/photos/frame/{photoId}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'photoPath': photoPath,
        'lat': lat,
        'lng': lng,
        'location': location,
      }),
    );

    if (response.statusCode == 200) {
      print('사진 업로드 성공: ${response.body}');
    } else {
      print('사진 업로드 실패: ${response.statusCode} - ${response.body}');
    }
  }
}
