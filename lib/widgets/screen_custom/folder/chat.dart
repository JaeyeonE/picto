import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto/viewmodles/chat_view_model.dart';
import '../../../models/folder/chat_message_model.dart';

class Chat extends GetView<ChatViewModel> {
  final int currentUserId;
  final int folderId;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Chat({
    Key? key,
    required this.currentUserId,
    required this.folderId,
  }) : super(key: key) {
    Get.put(ChatViewModel(
      folderId: folderId,
      currentUserId: currentUserId,
    ));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
                  final message = controller.messages[index];
                  final isCurrentUser = controller.isCurrentUser(message.senderId);

                  return MessageBubble(
                    message: message,
                    isCurrentUser: isCurrentUser,
                    onDelete: controller.deleteMessage,
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
    return Container(
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
    );
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    controller.sendMessage(text);
    _textController.clear();
    Future.delayed(
      const Duration(milliseconds: 100),
      _scrollToBottom,
    );
  }

  void _showMembersList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 멤버'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.members
              .map((member) => ListTile(
                    title: Text(member),
                  ))
              .toList(),
        )),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final Function(ChatMessage) onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (isCurrentUser) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('메시지 삭제'),
              content: const Text('이 메시지를 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    onDelete(message);
                    Navigator.pop(context);
                  },
                  child: const Text('삭제'),
                ),
              ],
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
      child: Text(
        message.senderId[0].toUpperCase(),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}