import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../models/folder/chat_message_model.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService;
  final int folderId;
  final int currentUserId;
  Timer? _reconnectTimer;

  List<ChatMessage> _messages = [];
  List<String> _members = [];
  bool _isLoading = true;
  bool _isConnected = false;
  StreamSubscription? _messageSubscription;

  ChatViewModel({
    required this.folderId,
    required this.currentUserId,
  }) : _chatService = ChatService(
          senderId: currentUserId,
        ) {
    _initializeChat();
  }

  // Getters
  List<ChatMessage> get messages => _messages;
  List<String> get members => _members;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;

  @override
  void dispose() {
    _leaveChat();
    _messageSubscription?.cancel();
    _reconnectTimer?.cancel(); 
    _chatService.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.initializeWebSocket(folderId);
      _isConnected = true;
      notifyListeners();
      
      await _chatService.enterChat(folderId);
      _subscribeToMessages();
    } catch (e) {
      print('Error initializing chat: $e');
      _isConnected = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToMessages() {
    final stream = _chatService.getChatStream();
    if (stream != null) {
      _messageSubscription?.cancel();
      _messageSubscription = stream.listen(
        (message) {
          switch (message.type) {
            case 'MESSAGE':
              _messages.add(message);
              notifyListeners();
              break;
            case 'DELETE':
              _messages.removeWhere((m) => m.senderId == message.senderId);
              notifyListeners();
              break;
            case 'ENTER':
              if (!_members.contains(message.senderId)) {
                _members.add(message.senderId);
                notifyListeners();
              }
              break;
            case 'EXIT':
              _members.remove(message.senderId);
              notifyListeners();
              break;
          }
        },
        onError: (error) {
          print('Error in chat message stream: $error');
          _isConnected = false;
          notifyListeners();
          _scheduleReconnect();
        },
        onDone: () {
          print('Chat stream closed');
          _isConnected = false;
          notifyListeners();
          _scheduleReconnect();
        },
      );
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isLoading) {
        _initializeChat();
      }
    });
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty || !_isConnected) return;
    
    try {
      _chatService.sendMessage(folderId, content);
    } catch (e) {
      print('Error sending message: $e');
      _tryReconnect();
    }
  }

  void deleteMessage(ChatMessage message) {
    if (!_isConnected) return;
    
    try {
      _chatService.deleteMessage(folderId, int.parse(message.senderId));
    } catch (e) {
      print('Error deleting message: $e');
      _tryReconnect();
    }
  }

  void _leaveChat() {
    if (!_isConnected) return;
    
    try {
      _chatService.leaveChat(folderId);
      _isConnected = false;
      _messages.clear();
      _members.clear();
      notifyListeners();
    } catch (e) {
      print('Error leaving chat: $e');
    }
  }

  Future<void> _tryReconnect() async {
    if (!_isConnected && !_isLoading) {
      await _initializeChat();
    }
  }

  Future<void> reconnect() async {
    if (_isConnected) return;
    await _initializeChat();
  }

  bool isCurrentUser(String senderId) => senderId == currentUserId.toString();
}