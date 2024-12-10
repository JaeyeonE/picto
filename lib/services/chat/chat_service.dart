import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../models/folder/chat_message_model.dart';
import '../../models/common/websocket_status.dart';

class ChatServiceException implements Exception {
  final String message;
  final String? code;
  ChatServiceException(this.message, {this.code});
  @override
  String toString() => 'ChatServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ChatService {
  final  baseUrl = 'http://3.35.246.85:8080/chatting-scheduler';
  final int _senderId;
  late final StompClient _stompClient;

  StreamController<ChatMessage>? _messageController;
  StreamController<WebSocketStatus>? _statusController;
  bool _isConnected = false;
  int? _currentFolderId;

  ChatService({required int senderId}) : _senderId = senderId {
    _messageController = StreamController<ChatMessage>.broadcast();
    _statusController = StreamController<WebSocketStatus>.broadcast();

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: baseUrl,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        onDebugMessage: print,
        stompConnectHeaders: {'senderId': _senderId.toString()},
        webSocketConnectHeaders: {'senderId': _senderId.toString()},
      ),
    );

    print('ChatService initialized for user: $_senderId');
  }

  Future<void> connect(int folderId) async {
    print('Connecting to STOMP for folder: $folderId');
    _currentFolderId = folderId;

    if (!_stompClient.connected) {
      try {
        _stompClient.activate();
      } catch (e) {
        print('STOMP connection failed: $e');
        _statusController?.add(WebSocketStatus.failed);
        throw ChatServiceException('Failed to connect: ${e.toString()}');
      }
    } else {
      await _subscribeToChatTopics();
    }
  }

  void _onConnect(StompFrame frame) async {
    print('Connected to STOMP');
    _isConnected = true;
    _statusController?.add(WebSocketStatus.connected);
    await _subscribeToChatTopics();
  }

  Future<void> _subscribeToChatTopics() async {
    print('currentFolderId : ${_currentFolderId}');
    if (_currentFolderId == null) return;

    // Subscribe to folder chat messages
    _stompClient.subscribe(
      destination: '/folder/${_currentFolderId}',
      callback: _handleMessage,
    );

    // Subscribe to user-specific messages
    // _stompClient.subscribe(
    //   destination: '/user/${_senderId}/queue/messages',
    //   callback: _handleMessage,
    // );
  }

  void _handleMessage(StompFrame frame) {
    try {
      if (frame.body != null) {

        final message = ChatMessage.fromJson(jsonDecode(frame.body!));
        print("전송 받은 메시지 : ");
        print(message.toString());
        _messageController?.add(message);
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  void _onDisconnect(StompFrame frame) {
    _isConnected = false;
    _statusController?.add(WebSocketStatus.disconnected);
    print('Disconnected from STOMP');
  }

  void _onStompError(StompFrame frame) {
    print('STOMP Error: ${frame.body}');
    _statusController?.add(WebSocketStatus.failed);
  }

  void _onWebSocketError(dynamic error) {
    print('WebSocket Error: $error');
    _statusController?.add(WebSocketStatus.failed);
  }

  // 채팅 수신
  Future<void> sendMessage(int folderId, String content) async {
    _validateConnection();

    final message = {
      'messageType': 'TALK',
      'senderId': _senderId,
      'folderId': folderId,
      'content': content,
      'sendDatetime': DateTime.now().millisecondsSinceEpoch,
    };
    _stompClient.send(
      destination: '/send/chat/message',
      body: jsonEncode(message),
    );

    // return ChatMessage.fromJson(message);
  }

  Future<void> enterChat(int folderId) async {
    _validateConnection();

    final message = {
      'messageType': 'ENTER',
      'senderId': _senderId,
      'folderId': folderId,
      'sendDatetime': DateTime.now().toUtc().millisecondsSinceEpoch,
    };

    _stompClient.send(
      destination: '/send/chat/enter',
      body: jsonEncode(message),
    );
  }

  Future<void> leaveChat(int folderId) async {
    _validateConnection();

    final message = {
      'messageType': 'EXIT',
      'senderId': _senderId,
      'folderId': folderId,
      'sendDatetime': DateTime.now().toUtc().millisecondsSinceEpoch,
    };

    _stompClient.send(
      destination: '/send/chat/exit',
      body: jsonEncode(message),
    );
  }

  // 지금 당장은 사용 XX
  Future<void> deleteMessage(int folderId, int messageId) async {
    _validateConnection();

    final message = {
      'messageType': 'DELETE',
      'chatId': messageId,
      'senderId': _senderId,
      'folderId': folderId,
      'sendDatetime': DateTime.now().toUtc().millisecondsSinceEpoch,
    };

    // 채팅 삭제는 http 요청
    // _stompClient.send(
    //   destination: '/pub/chat.delete',
    //   body: jsonEncode(message),
    // );
  }

  // 이전 채팅 기록 조회
  Future<List<ChatMessage>> getPreviousChat(int folderId) async {
    try {
      // API 호출
      final response = await Dio().get("$baseUrl/folders/$folderId/chat");

      // 응답 데이터 파싱
      final List<dynamic> chatData = response.data;
      print(chatData);
      // ChatMessage 객체 리스트로 변환
      final messages = chatData.map((messageData) {
        messageData["messageType"] = "TALK";
        return ChatMessage.fromJson(messageData);
      }).toList();

      // 시간순으로 정렬
      messages.sort((a, b) => a.sendDateTime.compareTo(b.sendDateTime));

      return messages;
    } catch (e) {
      print('Error fetching previous chat: $e');
      throw ChatServiceException('Failed to fetch chat history: ${e.toString()}');
    }
  }



  void _validateConnection() {
    if (!_stompClient.connected) {
      throw ChatServiceException('STOMP client not connected', code: 'NOT_CONNECTED');
    }
  }

  Stream<ChatMessage> get messageStream => _messageController!.stream;
  Stream<WebSocketStatus> get statusStream => _statusController!.stream;
  bool get isConnected => _stompClient.connected;

  void dispose() {
    print('Disposing ChatService');
    _stompClient.deactivate();
    _messageController?.close();
    _statusController?.close();
    _isConnected = false;
  }
}