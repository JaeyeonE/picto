import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/folder/chat_message_model.dart';
import '../services/session_service.dart';

class ChatService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://52.79.109.62:8080/chatting-scheduler';
  WebSocketChannel? _channel;
  final SessionService _sessionService;
  final int _senderId;
  bool _isConnected = false;
  
  // 재연결 관련 설정
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 2);
  int _reconnectAttempts = 0;

  ChatService({
    required int senderId,
    required SessionService sessionService,
  }) : _senderId = senderId,
       _sessionService = sessionService {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.headers = {'Content-Type': 'application/json'};
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // 인증 에러 처리
          throw Exception('Authentication failed');
        }
        return handler.next(error);
      }
    ));
  }

  // WebSocket 연결 설정
  Future<void> connectWebSocket(int folderId) async {
    if (_isConnected) {
      await _channel?.sink.close();
    }

    try {
      final wsUrl = Uri(
        scheme: 'wss',
        host: '52.79.109.62',
        port: 8080,
        path: '/chatting-scheduler/folder/$folderId/chat'
      );
      
      print('Connecting to Chat WebSocket: ${wsUrl.toString()}');
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
          _handleWebSocketError();
        },
        onDone: () {
          _isConnected = false;
          _handleWebSocketError();
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
      _handleWebSocketError();
    }
  }

  void _handleWebSocketError() {
    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectAttempts++;
      Future.delayed(reconnectDelay * _reconnectAttempts, () {
        if (!_isConnected) {
          print('Attempting to reconnect... Attempt $_reconnectAttempts');
          connectWebSocket(_senderId);
        }
      });
    } else {
      print('Max reconnection attempts reached');
      throw Exception('Unable to maintain WebSocket connection');
    }
  }

  Stream<ChatMessage>? getMessageStream() {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket is not connected');
    }
    return _channel?.stream.map((message) {
      try {
        return ChatMessage.fromJson(message);
      } catch (e) {
        print('Error parsing message: $e');
        rethrow;
      }
    });
  }

  // 세션/채팅방 메시지 목록 조회
  Future<List<ChatMessage>> getMessages(int folderId) async {
    try {
      final response = await _dio.get('$baseUrl/folders/$folderId/chat');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  // 채팅방 입장
  Future<void> enterChat(int folderId) async {
    try {
      // 세션 입장 먼저 수행
      await _sessionService.enterSession(_senderId);
      
      // 채팅방 입장
      await _dio.post(
        '$baseUrl/send/chat/enter',  // 경로 수정
        data: {
          'senderId': _senderId,
          'folderId': folderId,
          'messageType': 'ENTER',
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error entering chat: $e');
    }
  }

  // 채팅방 퇴장
  Future<void> leaveChat(int folderId) async {
    try {
      // 세션 퇴장 먼저 수행
      await _sessionService.exitSession(_senderId);
      
      await _dio.post(
        '$baseUrl/send/chat/leave',  // 경로 수정
        data: {
          'senderId': _senderId,
          'folderId': folderId,
          'messageType': 'EXIT',
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error leaving chat: $e');
    }
  }

  // 메시지 전송
  Future<void> sendMessage(int folderId, String content) async {
    try {
      await _dio.post(
        '$baseUrl/send/chat/message',  // 경로 수정
        data: {
          'senderId': _senderId,
          'folderId': folderId,
          'messageType': 'MESSAGE',
          'content': content,
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // 채팅방 참여자 목록 조회
  Future<List<String>> getChatMembers(int? folderId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/folders/$folderId/cheators',
      );
      
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        throw Exception('Failed to load chat members');
      }
    } catch (e) {
      throw Exception('Error fetching chat members: $e');
    }
  }

  Future<void> deleteMessage(int folderId, int senderId) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/chat',
        data: {
          'chatId': senderId,
          'senderId': senderId,
          'folderId': folderId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message');
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Future<void> dispose() async {
    _isConnected = false;
    await _channel?.sink.close();
    _sessionService.dispose();
  }
}