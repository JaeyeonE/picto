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
      await _chatService.initializeWebSocket(folderId);
      isConnected.value = true;
      
      // 채팅방 입장
      await _chatService.enterChat(folderId);
      
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
        (message) {
          switch (message.type) {
            case 'MESSAGE':
              messages.add(message);
              break;
            case 'DELETE':
              messages.removeWhere((m) => m.senderId == message.senderId);
              break;
            case 'ENTER':
              if (!members.contains(message.senderId)) {
                members.add(message.senderId);
              }
              break;
            case 'EXIT':
              members.remove(message.senderId);
              break;
          }
        },
        onError: (error) {
          print('Error in chat message stream: $error');
          isConnected.value = false;
          _tryReconnect();
        },
        onDone: () {
          print('Chat stream closed');
          isConnected.value = false;
          _tryReconnect();
        },
      );
    }
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty || !isConnected.value) return;
    
    try {
      _chatService.sendMessage(folderId, content);
    } catch (e) {
      print('Error sending message: $e');
      _tryReconnect();
    }
  }

  void deleteMessage(ChatMessage message) {
    if (!isConnected.value) return;
    
    try {
      _chatService.deleteMessage(folderId, int.parse(message.senderId));
    } catch (e) {
      print('Error deleting message: $e');
      _tryReconnect();
    }
  }

  void _leaveChat() {
    if (!isConnected.value) return;
    
    try {
      _chatService.leaveChat(folderId);
      isConnected.value = false;
      messages.clear();
      members.clear();
    } catch (e) {
      print('Error leaving chat: $e');
    }
  }

  Future<void> _tryReconnect() async {
    if (!isConnected.value && !isLoading.value) {
      await _initializeChat();
    }
  }

  Future<void> reconnect() async {
    if (isConnected.value) return;
    await _initializeChat();
  }

  bool isCurrentUser(String senderId) => senderId == currentUserId.toString();
}