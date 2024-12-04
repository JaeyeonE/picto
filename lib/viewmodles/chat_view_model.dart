import 'package:get/get.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../models/folder/chat_message_model.dart';
import 'session_controller.dart';

class ChatViewModel extends GetxController {
  final ChatService _chatService;
  final SessionController _sessionController;
  final int folderId;
  final int currentUserId;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<String> members = <String>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isConnected = false.obs;
  StreamSubscription? _messageSubscription;

  ChatViewModel({
    required this.folderId,
    required this.currentUserId,
  }) : _chatService = ChatService(
         sessionService: Get.find<SessionController>().sessionService,
         senderId: currentUserId,
       ),
       _sessionController = Get.find<SessionController>();

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
      // WebSocket 연결 설정
      await _chatService.initializeWebSocket(folderId);
      isConnected.value = true;

      // 병렬로 초기 데이터 로드
      await Future.wait([
        _loadMessages(),
        _loadMembers(),
        _chatService.enterChat(folderId),
      ]);

      _subscribeToMessages();
    } catch (e) {
      print('Error initializing chat: $e');
      isConnected.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeToMessages() {
    final stream = _chatService.getChatStream();
    if (stream != null) {
      _messageSubscription?.cancel();
      _messageSubscription = stream.listen(
        (message) => messages.add(message),
        onError: (error) {
          print('Error in chat message stream: $error');
          isConnected.value = false;
        },
        onDone: () {
          print('Chat stream closed');
          isConnected.value = false;
          // 필요한 경우 재연결 로직 추가
        },
      );
    }
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
    if (content.trim().isEmpty || !isConnected.value) return;
    
    try {
      await _chatService.sendMessage(folderId, content);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> deleteMessage(ChatMessage message) async {
    try {
      await _chatService.deleteMessage(folderId, int.parse(message.senderId));
      // 선택적: 로컬 메시지 목록에서도 제거
      messages.removeWhere((m) => m.senderId == message.senderId);
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  Future<void> _leaveChat() async {
    if (!isConnected.value) return;
    
    try {
      await _chatService.leaveChat(folderId);
      isConnected.value = false;
    } catch (e) {
      print('Error leaving chat: $e');
    }
  }

  Future<void> reconnect() async {
    if (isConnected.value) return;
    
    try {
      await _initializeChat();
    } catch (e) {
      print('Error reconnecting to chat: $e');
    }
  }

  bool isCurrentUser(String senderId) => senderId == currentUserId.toString();
}