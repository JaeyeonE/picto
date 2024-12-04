import 'package:flutter/material.dart';
<<<<<<< HEAD

=======
import 'package:get/get.dart';
>>>>>>> folder
import 'package:picto/viewmodles/chat_view_model.dart';
import 'package:picto/viewmodles/session_controller.dart';
import '../../../models/folder/chat_message_model.dart';
import '../../../services/session_service.dart';


class Chat extends GetView<ChatViewModel> {
  final int currentUserId;
  final int folderId;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SessionService _sessionService = SessionService();

  Chat({
    Key? key,
    required this.currentUserId,
    required this.folderId,
  }) : super(key: key) {
    // SessionController 먼저 초기화
    Get.put(SessionController(
      sessionId: currentUserId,  // currentUserId를 sessionId로 사용
    ));

    // ChatViewModel 초기화
    Get.put(ChatViewModel(
      folderId: folderId,
      currentUserId: currentUserId,
    ));
  }

  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text('Chat'),
      ),
      body: Text('채팅'),
      );
  }
}
=======
        title: Obx(() => Text('Chat (${controller.members.length}명)')),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _showMembersList(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index] as ChatMessage;  // 타입 캐스팅
                  final isCurrentUser = controller.isCurrentUser(message.senderId);

                  return MessageBubble(
                    message: message,
                    isCurrentUser: isCurrentUser,
                    onDelete: () => _handleDelete(context, message),  // 삭제 핸들러 분리
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        );
      }),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(  // 키보드 영역 처리
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 4,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSubmit,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmit(_textController.text),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    
    final trimmedText = text.trim();
    _textController.clear();
    
    controller.sendMessage(trimmedText); // await 제거
    _scrollToBottom();
  }

  void _handleDelete(BuildContext context, ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 삭제'),
        content: const Text('이 메시지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteMessage(message); // await 제거
    }
  }

  void _showMembersList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 멤버'),
        content: Obx(() {
          if (controller.members.isEmpty) {
            return const Text('멤버가 없습니다.');
          }

          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.members.length,
              itemBuilder: (context, index) {
                final member = controller.members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      member[0].toUpperCase(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(member),
                );
              },
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final VoidCallback onDelete;  // Function 타입 대신 VoidCallback 사용

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isCurrentUser ? onDelete : null,  // 현재 사용자의 메시지만 삭제 가능
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,  // 메시지와 아바타 하단 정렬
          children: [
            if (!isCurrentUser) _buildAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.senderId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Text(message.content),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.sendDateTime),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isCurrentUser) _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.grey[300],
      radius: 16,  // 크기 조정
      child: Text(
        message.senderId[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
>>>>>>> folder
