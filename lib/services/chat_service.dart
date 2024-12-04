import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/folder/chat_message_model.dart';
import 'session_service.dart';

class ChatService {
  final SessionService _sessionService;
  final int _senderId;
  WebSocketChannel? _channel;
  Stream<ChatMessage>? _messageStream;
  bool _isConnected = false;

  ChatService({
    required SessionService sessionService,
    required int senderId,
  }) : _sessionService = sessionService,
       _senderId = senderId;

  Future<void> initializeWebSocket(int folderId) async {
    final wsUrl = Uri(
      scheme: 'ws',
      host: '52.79.109.62',
      port: 8080,
      path: '/chatting-scheduler/folder/$folderId/chat'
    );

    try {
      await _channel?.sink.close();
      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;

      _messageStream = _channel?.stream.map((data) {
        final jsonData = jsonDecode(data);
        return ChatMessage.fromJson(jsonData);
      });

      print('Chat WebSocket connected: $wsUrl');
    } catch (e) {
      _isConnected = false;
      print('Chat WebSocket connection failed: $e');
      rethrow;
    }
  }

  void sendMessage(int folderId, String content) {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    final message = {
      'type': 'MESSAGE',
      'senderId': _senderId,
      'folderId': folderId,
      'content': content,
      'sendDateTime': DateTime.now().toUtc().toIso8601String(),
    };

    _channel?.sink.add(jsonEncode(message));
  }

  Future<void> enterChat(int folderId) async {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    // 세션 입장
    _sessionService.enterSession(_senderId);

    // 채팅방 입장 메시지 전송
    final message = {
      'type': 'ENTER',
      'senderId': _senderId,
      'folderId': folderId,
      'sendDateTime': DateTime.now().toUtc().toIso8601String(),
    };

    _channel?.sink.add(jsonEncode(message));
  }

  Future<void> leaveChat(int folderId) async {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    // 세션 퇴장
    _sessionService.exitSession(_senderId);

    // 채팅방 퇴장 메시지 전송
    final message = {
      'type': 'EXIT',
      'senderId': _senderId,
      'folderId': folderId,
      'sendDateTime': DateTime.now().toUtc().toIso8601String(),
    };

    _channel?.sink.add(jsonEncode(message));
  }

  void deleteMessage(int folderId, int messageId) {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    final message = {
      'type': 'DELETE',
      'chatId': messageId,
      'senderId': _senderId,
      'folderId': folderId,
      'sendDateTime': DateTime.now().toUtc().toIso8601String(),
    };

    _channel?.sink.add(jsonEncode(message));
  }

  Stream<ChatMessage>? getChatStream() => _messageStream;

  bool get isConnected => _isConnected;

  void dispose() {
    _channel?.sink.close();
    _messageStream = null;
    _isConnected = false;
  }
}
