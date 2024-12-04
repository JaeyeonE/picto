import 'package:get/get.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../models/folder/chat_message_model.dart';
import 'session_controller.dart';
import '../services/session_service.dart';


class ChatViewModel extends GetxController {
  final ChatService _chatService;
  final SessionController _sessionController;
  final int folderId;
  final int currentUserId;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;  // 타입 명시
  final RxList<String> members = <String>[].obs;  // 타입 명시
  final RxBool isLoading = true.obs;
  StreamSubscription? _messageSubscription;

  ChatViewModel({
    required this.folderId,
    required this.currentUserId,
  }) : _chatService = ChatService(
         senderId: currentUserId,
         sessionService: Get.find<SessionController>().sessionService,
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

  Future<void> _initializeChat() async {  // 반환 타입 명시
    isLoading.value = true;

    try {
      // WebSocket 연결
      _chatService.connectWebSocket(currentUserId);
      
      // 초기 데이터 로드를 병렬로 처리
      await Future.wait([
        _loadMessages(),
        _loadMembers(),
        _chatService.enterChat(currentUserId),  // senderId는 서비스에서 관리
      ]);

      // 실시간 메시지 수신 시작
      _subscribeToMessages();
    } catch (e) {
      print('Error initializing chat: $e');
      // 에러 처리를 위한 상태 추가 가능
      // error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeToMessages() {
    final stream = _chatService.getMessageStream();
    if (stream != null) {
      _messageSubscription = stream.listen(
        (message) => messages.add(message),
        onError: (error) => print('Error in message stream: $error'),
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
    if (content.trim().isEmpty) return;
    
    try {
      await _chatService.sendMessage(folderId, content);  // senderId는 서비스에서 관리
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
      await _chatService.leaveChat(folderId);  // senderId는 서비스에서 관리
    } catch (e) {
      print('Error leaving chat: $e');
    }
  }

  bool isCurrentUser(String senderId) => senderId == currentUserId.toString();
}