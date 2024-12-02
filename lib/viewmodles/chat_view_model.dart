import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService;
  final String folderId;
  final String currentUserId;
  List<ChatMessage> _messages = [];
  List<String> _members = [];
  bool _isLoading = false;
  StreamSubscription? _messageSubscription;

  ChatViewModel(this._chatService, this.folderId, this.currentUserId) {
    _initializeChat();
  }

  List<ChatMessage> get messages => _messages;
  List<String> get members => _members;
  bool get isLoading => _isLoading;

  Future<void> _initializeChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.enterChat(folderId, currentUserId);
      
      await Future.wait([
        _loadMessages(),
        _loadMembers(),
      ]);

      _startMessagePolling();
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getMessages(folderId);
      _messages = messages;
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _loadMembers() async {
    try {
      final members = await _chatService.getChatMembers(folderId);
      _members = members;
      notifyListeners();
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  void _startMessagePolling() {
    _messageSubscription?.cancel();
    _messageSubscription = Stream.periodic(const Duration(seconds: 2)).listen((_) {
      _loadMessages();
    });
  }

  Future<void> sendMessage(String content) async {
    try {
      await _chatService.sendMessage(folderId, currentUserId, content);
      await _loadMessages();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  void dispose() {
    _leaveChat();
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _leaveChat() async {
    try {
      await _chatService.leaveChat(folderId, currentUserId);
    } catch (e) {
      print('Error leaving chat: $e');
    }
  }
}