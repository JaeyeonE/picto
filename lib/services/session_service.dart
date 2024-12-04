import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/common/session_message.dart';

class SessionService {
  WebSocketChannel? _channel;
  Stream<SessionMessage>? _messageStream;
  bool _isConnected = false;

  Future<void> initializeWebSocket(int sessionId) async {
    final wsUrl = Uri(
      scheme: 'ws',
      host: '52.79.109.62',
      port: 8085,
      path: '/session-scheduler/session/$sessionId'
    );

    try {
      await _channel?.sink.close();
      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;
      
      _messageStream = _channel?.stream.map((data) {
        final jsonData = jsonDecode(data);
        return SessionMessage.fromJson(jsonData);
      });

      print('Session WebSocket connected: $wsUrl');
    } catch (e) {
      _isConnected = false;
      print('Session WebSocket connection failed: $e');
      rethrow;
    }
  }

  void sendLocation(int senderId, double lat, double lng) {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    final message = {
      'type': 'LOCATION',
      'senderId': senderId,
      'lat': lat,
      'lng': lng,
      'sendDateTime': DateTime.now().toUtc().toIso8601String(),
    };

    _channel?.sink.add(jsonEncode(message));
  }

  void enterSession(int senderId) {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    final message = {
      'type': 'ENTER',
      'senderId': senderId,
      'sendDateTime': DateTime.now().toUtc().toIso8601String(),
    };

    _channel?.sink.add(jsonEncode(message));
  }

  void exitSession(int senderId) {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    final message = {
      'type': 'EXIT',
      'senderId': senderId,
      'sendDateTime': DateTime.now().toUtc().toIso8601String(),
    };

    _channel?.sink.add(jsonEncode(message));
  }

  Stream<SessionMessage>? getSessionStream() => _messageStream;

  bool get isConnected => _isConnected;

  void dispose() {
    _channel?.sink.close();
    _messageStream = null;
    _isConnected = false;
  }
}