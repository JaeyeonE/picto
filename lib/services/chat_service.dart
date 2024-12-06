import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/folder/chat_message_model.dart';
import '../models/common/websocket_status.dart';
import 'session_service.dart';

class ChatServiceException implements Exception {
  final String message;
  final String? code;
  ChatServiceException(this.message, {this.code});
  @override
  String toString() => 'ChatServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ChatService {
  static const int maxReconnectAttempts = 3;
  static const Duration reconnectDelay = Duration(seconds: 5);
  
  final SessionService _sessionService;
  final int _senderId;
  int? _currentFolderId;
  
  WebSocketChannel? _channel;
  Stream<ChatMessage>? _messageStream;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  StreamController<WebSocketStatus>? _statusController;
  
  int _reconnectAttempts = 0;
  bool _isReconnecting = false;

  ChatService({
    required SessionService sessionService,
    required int senderId,
  }) : _sessionService = sessionService,
       _senderId = senderId {
    _statusController = StreamController<WebSocketStatus>.broadcast();
    print('ChatService initialized for user: $_senderId');
  }

  Future<void> initializeWebSocket(int folderId) async {
    print('Initializing WebSocket for folder: $folderId');
    _currentFolderId = folderId;
    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    if (_currentFolderId == null) return;
    
    final wsUrl = Uri(
      scheme: 'ws',
      host: '52.79.109.62',
      port: 8080,
      path: '/chatting-scheduler/folder/$_currentFolderId/chat'
    );

    try {
      await _channel?.sink.close();
      _channel = WebSocketChannel.connect(wsUrl);
      
      _messageStream = _channel?.stream.map((data) {
        try {
          final jsonData = jsonDecode(data);
          return ChatMessage.fromJson(jsonData);
        } catch (e) {
          print('Error parsing message: $e');
          throw ChatServiceException('Invalid message format', code: 'PARSE_ERROR');
        }
      }).handleError((error) {
        print('Stream error: $error');
        _handleConnectionError();
      });

      _isConnected = true;
      _reconnectAttempts = 0;
      _isReconnecting = false;
      _setupHeartbeat();
      _statusController?.add(WebSocketStatus.connected);
      print('WebSocket connected to: $wsUrl');
      
    } catch (e) {
      _isConnected = false;
      print('WebSocket connection failed: $e');
      _handleConnectionError();
    }
  }

  void _handleConnectionError() {
    if (_isReconnecting) return;
    
    _isConnected = false;
    _statusController?.add(WebSocketStatus.disconnected);
    
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('Max reconnection attempts reached');
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;
    
    print('Attempting to reconnect in ${reconnectDelay.inSeconds} seconds (Attempt $_reconnectAttempts/$maxReconnectAttempts)');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () async {
      try {
        await _connectWebSocket();
      } catch (e) {
        print('Reconnection attempt failed: $e');
        _handleConnectionError();
      }
    });
  }

  void _setupHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        try {
          _channel?.sink.add(jsonEncode({
            'type': 'PING',
            'senderId': _senderId,
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          }));
        } catch (e) {
          print('Heartbeat failed: $e');
          _handleConnectionError();
        }
      }
    });
  }

  Future<void> sendMessage(int folderId, String content) async {
    print('Attempting to send message to folder: $folderId');
    _validateConnection();

    final message = {
      'type': 'MESSAGE',
      'senderId': _senderId,
      'folderId': folderId,
      'content': content,
      'sendDateTime': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      _channel?.sink.add(jsonEncode(message));
      print('Message sent successfully');
    } catch (e) {
      print('Failed to send message: $e');
      throw ChatServiceException('Failed to send message: ${e.toString()}');
    }
  }

  Future<void> enterChat(int folderId) async {
    print('Entering chat for folder: $folderId');
    _validateConnection();

    try {
      await _sessionService.enterSession(_senderId);
      final message = {
        'type': 'ENTER',
        'senderId': _senderId,
        'folderId': folderId,
        'sendDateTime': DateTime.now().toUtc().toIso8601String(),
      };
      _channel?.sink.add(jsonEncode(message));
      print('Successfully entered chat');
    } catch (e) {
      print('Failed to enter chat: $e');
      throw ChatServiceException('Failed to enter chat: ${e.toString()}');
    }
  }

  Future<void> leaveChat(int folderId) async {
    print('Leaving chat for folder: $folderId');
    _validateConnection();

    try {
      await _sessionService.exitSession(_senderId);
      final message = {
        'type': 'EXIT',
        'senderId': _senderId,
        'folderId': folderId,
        'sendDateTime': DateTime.now().toUtc().toIso8601String(),
      };
      _channel?.sink.add(jsonEncode(message));
      print('Successfully left chat');
    } catch (e) {
      print('Failed to leave chat: $e');
      throw ChatServiceException('Failed to leave chat: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(int folderId, int messageId) async {
    print('Deleting message: $messageId from folder: $folderId');
    _validateConnection();

    try {
      final message = {
        'type': 'DELETE',
        'chatId': messageId,
        'senderId': _senderId,
        'folderId': folderId,
        'sendDateTime': DateTime.now().toUtc().toIso8601String(),
      };
      _channel?.sink.add(jsonEncode(message));
      print('Successfully deleted message');
    } catch (e) {
      print('Failed to delete message: $e');
      throw ChatServiceException('Failed to delete message: ${e.toString()}');
    }
  }

  void _validateConnection() {
    if (!_isConnected) {
      throw ChatServiceException('WebSocket not connected', code: 'NOT_CONNECTED');
    }
  }

  Stream<ChatMessage>? getChatStream() => _messageStream;
  Stream<WebSocketStatus>? getStatusStream() => _statusController?.stream;
  bool get isConnected => _isConnected;

  void dispose() {
    print('Disposing ChatService');
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageStream = null;
    _isConnected = false;
    _statusController?.close();
  }
}