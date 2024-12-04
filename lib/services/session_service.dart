import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/common/session_message.dart';

class SessionService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://52.79.109.62:8085/session-scheduler';
  final int wsPort = 8085; // WebSocket 포트를 명시적으로 설정
  WebSocketChannel? _channel;
  bool _isConnected = false;

    // 재연결 관련 설정
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 2);
  int _reconnectAttempts = 0;

   SessionService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.headers = {'Content-Type': 'application/json'};
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  // WebSocket 연결 설정
Future<void> connectWebSocket(int sessionId) async {
    if (_isConnected) {
      await _channel?.sink.close();
    }

    try {
      final wsUrl = Uri(
        scheme: 'wss',
        host: '52.79.109.62',
        port: wsPort,
        path: '/session-scheduler/session/$sessionId'
      );
      
      print('Connecting to Session WebSocket: ${wsUrl.toString()}');
      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;
      _reconnectAttempts = 0;

      // 연결 상태 모니터링
      _channel?.stream.listen(
        (message) {
          // 메시지 처리
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleWebSocketError(sessionId);
        },
        onDone: () {
          _isConnected = false;
          _handleWebSocketError(sessionId);
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
      _handleWebSocketError(sessionId);
    }
  }

    void _handleWebSocketError(int sessionId) {
    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectAttempts++;
      Future.delayed(reconnectDelay * _reconnectAttempts, () {
        if (!_isConnected) {
          print('Attempting to reconnect... Attempt $_reconnectAttempts');
          connectWebSocket(sessionId);
        }
      });
    } else {
      print('Max reconnection attempts reached');
      throw Exception('Unable to maintain WebSocket connection');
    }
  }
  // 위치 정보 전송
  Future<void> sendLocation(int senderId, double lat, double lng) async {
    try {
      await _dio.post(
        '$baseUrl/send/session/location',
        data: {
          'senderId': senderId,
          'lat': lat,
          'lng': lng,
          'messageType': 'LOCATION',
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
      print('connection succesful');
    } catch (e) {
      throw Exception('Error sending location: $e');
    }
  }

  // 세션 퇴장
  Future<void> exitSession(int senderId) async {
    try {
      await _dio.post(
        '$baseUrl/send/session/exit',
        data: {
          'senderId': senderId,
        },
      );
      print('exiting');
    } catch (e) {
      throw Exception('Error exiting session: $e');
    }
  }

  // 세션 입장
  Future<void> enterSession(int senderId) async {
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
 Stream<SessionMessage> getSessionMessages(int sessionId) {
    if (!_isConnected) {
      connectWebSocket(sessionId);
    }
    
    return _channel!.stream.map((message) {
      try {
        return SessionMessage.fromJson(message);
      } catch (e) {
        print('Error parsing session message: $e');
        rethrow;
      }
    });
  }

  void dispose() {
    _channel?.sink.close();
  }
}