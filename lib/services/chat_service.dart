import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/folder/chat_message_model.dart';
import '../models/folder/status_model.dart';

class ChatService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://52.79.109.62:8080';
  WebSocketChannel? _channel;

  ChatService() {
    _dio.options.headers = {'Content-Type': 'application/json'};
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  // WebSocket 연결 설정
  void connectWebSocket(int folderId) {
    final wsUrl = Uri.parse('ws://${baseUrl.substring(7)}/ChattingScheduler/session/1');
    _channel = WebSocketChannel.connect(wsUrl);
  }

  // 채팅방 메시지 스트림
  Stream<ChatMessage>? getMessageStream() {
    return _channel?.stream.map((message) => ChatMessage.fromJson(message));
  }

  // 세션/채팅방 메시지 목록 조회
  Future<List<ChatMessage>> getMessages(int folderId) async {
    try {
      final response = await _dio.get('$baseUrl/ChattingScheduler/session/1');
      
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
  Future<void> enterChat(int? folderId, int? senderId) async {
    try {
      await _dio.post(
        '$baseUrl/session-scheduler/send/session/enter',
        data: {
          'senderId': 1,
          'folderId': 1,
          'messageType': 'ENTER',
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error entering chat: $e');
    }
  }

  // 채팅방 퇴장
  Future<void> leaveChat(int? folderId, int? senderId) async {
    try {
      await _dio.post(
        '$baseUrl/session-scheduler/send/session/exit',
        data: {
          'senderId': 1,
          'folderId': 1,
          'messageType': 'EXIT',
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error leaving chat: $e');
    }
  }

  // 메시지 전송
  Future<void> sendMessage(int? folderId, int? senderId, String content) async {
    try {
      await _dio.post(
        '$baseUrl/ChattingScheduler/send/chat/message',
        data: {
          'senderId': 1,
          'folderId': 1,
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
        '$baseUrl/session-scheduler/folder/1/cheator',
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
        '$baseUrl/ChattingScheduler/chat',
        data: {
          'chatId': 1,
          'senderId': 1,
          'folderId': 1,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message');
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  void dispose() {
    _channel?.sink.close();
  }
}