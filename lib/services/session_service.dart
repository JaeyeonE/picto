import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/common/session_message.dart';

class SessionService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://52.79.109.62:8080/session-scheduler';
  WebSocketChannel? _channel;

  // WebSocket 연결 설정
  void connectWebSocket(String sessionId) {
    final wsUrl = Uri.parse('ws://52.79.109.62:8085/session-scheduler/session/$sessionId');
    _channel = WebSocketChannel.connect(wsUrl);
  }

  // 위치 정보 전송
  Future<void> sendLocation(String senderId, double lat, double lng) async {
    try {
      await _dio.post(
        '$baseUrl/send/session/location',
        data: {
          'senderId': 1,
          'lat': lat,
          'lng': lng,
          'messageType': 'LOCATION',
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error sending location: $e');
    }
  }

  // 세션 퇴장
  Future<void> exitSession(String senderId) async {
    try {
      await _dio.post(
        '$baseUrl/send/session/exit',
        data: {
          'senderId': senderId,
        },
      );
    } catch (e) {
      throw Exception('Error exiting session: $e');
    }
  }

  // 세션 입장
  Future<void> enterSession(String senderId) async {
    try {
      await _dio.post(
        '$baseUrl/send/session/enter',
        data: {
          'senderId': senderId,
        },
      );
    } catch (e) {
      throw Exception('Error entering session: $e');
    }
  }

  // 세션 메시지 스트림 구독
  Stream<SessionMessage> getSessionMessages(String sessionId) {
    connectWebSocket(sessionId);
    
    return _channel!.stream.map((message) {
      return SessionMessage.fromJson(message);
    });
  }

  void dispose() {
    _channel?.sink.close();
  }
}