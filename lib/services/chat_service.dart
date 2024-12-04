import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../models/folder/chat_message_model.dart';
import 'session_service.dart';

class ChatService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://52.79.109.62:8080/chatting-scheduler';
  final SessionService _sessionService;
  final int _senderId;
  WebSocketChannel? _channel;
  Stream<ChatMessage>? _messageStream;

  ChatService({
    required SessionService sessionService,
    required int senderId,
  }) : _sessionService = sessionService,
       _senderId = senderId {
    _initDio();
  }

  void _initDio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 3)
      ..headers = {'Content-Type': 'application/json'};
  }

  Future<void> initializeWebSocket(int folderId) async {
    final wsUrl = Uri.parse('wss://52.79.109.62:8080/chatting-scheduler/folder/$folderId/chat');

    try {
      _channel?.sink.close();
      // IOWebSocketChannel 사용 및 설정 추가
      _channel = IOWebSocketChannel.connect(
        wsUrl,
        connectTimeout: const Duration(seconds: 5),
        protocols: ['websocket'],
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
          print('Received chat data: $data');  // 데이터 수신 로깅
          return ChatMessage.fromJson(data);
        });
      }

      print('Chat WebSocket initialized: $wsUrl');
    } catch (e) {
      print('Chat WebSocket initialization failed: $e');
      rethrow;
    }
  }

  Stream<ChatMessage>? getChatStream() => _messageStream;

  Future<List<ChatMessage>> getMessages(int folderId) async {
    try {
      final response = await _dio.get('/folders/$folderId/chat');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch messages');
    } catch (e) {
      print('Failed to get messages: $e');
      rethrow;
    }
  }

  Future<void> enterChat(int folderId) async {
    try {
      await _sessionService.enterSession(_senderId);
      
      final data = {
        'senderId': _senderId,
        'folderId': folderId,
        'messageType': 'ENTER',
        'sendDateTime': DateTime.now().toUtc().toIso8601String(),
      };
      
      await _dio.post('/send/chat/enter', data: data);
      print('Chat room entered successfully');
    } catch (e) {
      print('Failed to enter chat: $e');
      rethrow;
    }
  }

  Future<void> leaveChat(int folderId) async {
    try {
      await _sessionService.exitSession(_senderId);
      
      final data = {
        'senderId': _senderId,
        'folderId': folderId,
        'messageType': 'EXIT',
        'sendDateTime': DateTime.now().toUtc().toIso8601String(),
      };
      
      await _dio.post('/send/chat/leave', data: data);
      print('Chat room left successfully');
    } catch (e) {
      print('Failed to leave chat: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(int folderId, String content) async {
    try {
      final data = {
        'senderId': _senderId,
        'folderId': folderId,
        'messageType': 'MESSAGE',
        'content': content,
        'sendDateTime': DateTime.now().toUtc().toIso8601String(),
      };
      
      await _dio.post('/send/chat/message', data: data);
      print('Message sent successfully');
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  Future<List<String>> getChatMembers(int folderId) async {
    try {
      final response = await _dio.get('/folders/$folderId/cheators');
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      }
      throw Exception('Failed to fetch chat members');
    } catch (e) {
      print('Failed to get chat members: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(int folderId, int messageId) async {
    try {
      final data = {
        'chatId': messageId,
        'senderId': _senderId,
        'folderId': folderId,
      };
      
      final response = await _dio.delete('/chat', data: data);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete message');
      }
      print('Message deleted successfully');
    } catch (e) {
      print('Failed to delete message: $e');
      rethrow;
    }
  }

  void dispose() {
    _channel?.sink.close();
    _messageStream = null;
  }
}