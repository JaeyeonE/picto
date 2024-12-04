import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../models/common/session_message.dart';

class SessionService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://52.79.109.62:8085/session-scheduler';
  WebSocketChannel? _channel;
  Stream<SessionMessage>? _messageStream;

  SessionService() {
    _initDio();
  }

  void _initDio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 3)
      ..headers = {'Content-Type': 'application/json'};
  }

  Future<void> initializeWebSocket(int sessionId) async {
    final wsUrl = Uri.parse('ws://52.79.109.62:8085/session-scheduler/session/$sessionId');

    try {
      _channel?.sink.close();
      // IOWebSocketChannel 사용 및 설정 추가
      _channel = IOWebSocketChannel.connect(
        wsUrl,
        connectTimeout: const Duration(seconds: 5),
        protocols: ['websocket'],  // 프로토콜 명시
        headers: {
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
          'Cache-Control': 'no-cache',
          'Content-Type': 'application/json',
        },
      );

      // 연결 확인을 위한 ping 설정
      if (_channel != null) {
        _messageStream = _channel!.stream.map((data) {
          print('Received session data: $data');  // 데이터 수신 로깅
          return SessionMessage.fromJson(data);
        });
      }
      
      print('Session WebSocket initialized: $wsUrl');
    } catch (e) {
      print('Session WebSocket initialization failed: $e');
      rethrow;
    }
  }

  Stream<SessionMessage>? getSessionStream() => _messageStream;

  Future<void> sendLocation(int senderId, double lat, double lng) async {
    try {
      final data = {
        'senderId': senderId,
        'lat': lat,
        'lng': lng,
        'messageType': 'LOCATION',
        'sendDateTime': DateTime.now().toUtc().toIso8601String(),
      };
      
      await _dio.post('/send/session/location', data: data);
      print('Location sent successfully');
    } catch (e) {
      print('Failed to send location: $e');
      rethrow;
    }
  }

  Future<void> enterSession(int senderId) async {
    try {
      await _dio.post('/send/session/enter', data: {'senderId': senderId});
      print('Session entered successfully');
    } catch (e) {
      print('Failed to enter session: $e');
      rethrow;
    }
  }

  Future<void> exitSession(int senderId) async {
    try {
      await _dio.post('/send/session/exit', data: {'senderId': senderId});
      print('Session exited successfully');
    } catch (e) {
      print('Failed to exit session: $e');
      rethrow;
    }
  }

  void dispose() {
    _channel?.sink.close();
    _messageStream = null;
  }
}