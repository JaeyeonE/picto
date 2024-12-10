import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/chat/chat_service.dart';
import '../models/folder/chat_message_model.dart';

// Chatting View Model 채팅화면 구성에 필요한 요소들, 서비스 모음
class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService;
  final int folderId;
  final int currentUserId;
  Timer? _reconnectTimer;

  // 실제 들어오는 채팅
  List<ChatMessage> _messages = [];
  // 접속 중인 사용자
  List<int> _members = [];
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
  List<int> get members => _members;
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
      final previousMessages = await _chatService.getPreviousChat(folderId);
      _messages = previousMessages;
      notifyListeners();

      await _chatService.connect(folderId);
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
  // 전송되는 메시지 처리
  void _subscribeToMessages() {
    final stream = _chatService.messageStream;
    _messageSubscription?.cancel();
    _messageSubscription = stream.listen(
          (message) {
        switch (message.messageType) {
          case 'TALK':
          // 중복 메시지 체크 추가
            if (!_messages.any((m) =>
            m.senderId == message.senderId &&
                m.sendDateTime == message.sendDateTime)) {
              _messages = [..._messages, message]; // 불변성 유지하며 메시지 추가
              notifyListeners();
            }
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

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isLoading) {
        _initializeChat();
      }
    });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || !_isConnected) return;

    try {
      final message = {
        'messageType': 'TALK',
        'senderId': currentUserId,
        'folderId': folderId,
        'content': content,
        'sendDatetime': DateTime.now().millisecondsSinceEpoch,
      };

      print('Sending message: $message'); // 디버그 로그 추가

      // 즉시 로컬 메시지 추가
      // final localMessage = ChatMessage.fromJson(message);
      // _messages = [..._messages, localMessage];
      // notifyListeners();

      // 서버로 전송
      await _chatService.sendMessage(folderId, content);
    } catch (e) {
      print('Error sending message: $e');
      // 에러 발생 시 마지막 메시지 제거
      // _messages = _messages.sublist(0, _messages.length - 1);
      // notifyListeners();
      _tryReconnect();
    }
  }

  void deleteMessage(ChatMessage message) {
    if (!_isConnected) return;
    
    try {
      _chatService.deleteMessage(folderId, message.senderId);
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

  bool isCurrentUser(int senderId) => senderId == currentUserId;  // 정수형으로 직접 비교
}