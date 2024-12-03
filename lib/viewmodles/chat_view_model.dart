import 'package:get/get.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../models/folder/chat_message_model.dart';


class ChatViewModel extends GetxController {
  final ChatService _chatService = ChatService();
  final int folderId;
  final int currentUserId;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<String> members = <String>[].obs;
  final RxBool isLoading = true.obs;
  StreamSubscription? _messageSubscription;

  ChatViewModel({
    required this.folderId,
    required this.currentUserId,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  @override
  void onClose() {
    _leaveChat();
    _messageSubscription?.cancel();
    _chatService.dispose();
    super.onClose();
  }

  Future<void> _initializeChat() async {
    isLoading.value = true;

    try {
      // WebSocket 연결 및 세션 입장
      _chatService.connectWebSocket(folderId);
      await _chatService.enterChat(folderId, currentUserId);
      
      // 초기 데이터 로드
      await Future.wait([
        _loadMessages(),
        _loadMembers(),
      ]);

      // 실시간 메시지 수신 시작
      _subscribeToMessages();
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeToMessages() {
    _messageSubscription = _chatService.getMessageStream()?.listen((message) {
      messages.add(message);
    });
  }

  Future<void> _loadMessages() async {
    try {
      final newMessages = await _chatService.getMessages(folderId);
      messages.value = newMessages;
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _loadMembers() async {
    try {
      final chatMembers = await _chatService.getChatMembers(folderId);
      members.value = chatMembers;
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    try {
      await _chatService.sendMessage(folderId, currentUserId, content);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> deleteMessage(ChatMessage message) async {
    try {
      await _chatService.deleteMessage(folderId, int.parse(message.senderId));
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  Future<void> _leaveChat() async {
    try {
      await _chatService.leaveChat(folderId, currentUserId);
    } catch (e) {
      print('Error leaving chat: $e');
    }
  }

  bool isCurrentUser(String senderId) => senderId == currentUserId.toString();
}