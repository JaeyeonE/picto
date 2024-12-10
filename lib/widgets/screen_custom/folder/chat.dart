import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/chat_view_model.dart';
import 'package:picto/viewmodles/folder_view_model.dart';
import 'package:picto/services/session/session_service.dart';
import '../../../models/folder/chat_message_model.dart';
import '../../../services/chat/message_item.dart';


class Chat extends StatefulWidget {
  final int currentUserId;
  final int folderId;

  const Chat({
    Key? key,
    required this.currentUserId,
    required this.folderId,
  }) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  //ListView.builder의 아이템을 별도 위젯(MessageItem)으로 분리
  // 메시지 목록
  Widget _buildMessageList() {
    return Consumer<ChatViewModel>(
      builder: (context, chatVM, _) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: chatVM.messages.length,
          itemBuilder: (context, index) {
            final message = chatVM.messages[index];
            return MessageItem(
              message: message,
              isCurrentUser: chatVM.isCurrentUser(message.senderId),
              onDelete: () => _handleDelete(context, message),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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
  void initState() {
    super.initState();
    // 폴더 사용자 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FolderViewModel>().loadFolderUsers(widget.folderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(
        folderId: widget.folderId,
        currentUserId: widget.currentUserId,
      ),
      child: Builder(builder: (context) {
        return _buildScaffold(context);
      }),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Consumer2<ChatViewModel, FolderViewModel>(
          builder: (context, chatVM, folderVM, child) {
            final memberCount = folderVM.folderUsers.length;
            return Text('채팅방 아이디 : (${folderVM.currentFolderId})');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _showMembersList(context),
          ),
          // 접속 비접속 확인
          Consumer<ChatViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: Icon(
                  Icons.wifi,
                  color: viewModel.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: viewModel.isLoading ? null : viewModel.reconnect,
              );
            },
          ),
        ],
      ),
      body: Consumer2<ChatViewModel, SessionService>(
        builder: (context, chatVM, sessionService, child) {
          if (!sessionService.isConnected) {
            return const Center(
              child: Text('세션이 연결되어 있지 않습니다. 다시 로그인해주세요.'),
            );
          }

          if (chatVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!chatVM.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('채팅 연결이 끊어졌습니다.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: chatVM.reconnect,
                    child: const Text('재연결'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child : _buildMessageList()
              ),
              if (chatVM.isConnected) _buildMessageInput(context),
            ],
          );
        },
      ),
    );
  }

  // 메시지 입력
  Widget _buildMessageInput(BuildContext context) {
    return SafeArea(
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
                // onSubmitted: (text) => _handleSubmit(context, text),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => {
                setState(() {
                  _handleSubmit(context, _textController.text);
                })
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    
    final trimmedText = text.trim();
    _textController.clear();
    
    final chatVM = context.read<ChatViewModel>();
    if (chatVM.isConnected) {
      chatVM.sendMessage(trimmedText);
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메시지를 전송할 수 없습니다. 연결 상태를 확인해주세요.')),
      );
    }
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
      context.read<ChatViewModel>().deleteMessage(message);
    }
  }

  // 여기서 오류 발생 -> Provider<FolderViewModel> 이 등록안됨
  // 미구현 폴더 접속자를 계속해서 조회하는 로직은 구현 x
  void _showMembersList(BuildContext context) {
    final folderVM = context.read<FolderViewModel>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('채팅방 멤버'),
        // 등록된 folderVM 읽어서 대기
        content: ValueListenableBuilder(
          valueListenable: ValueNotifier(folderVM.userProfiles),
          builder: (context, profiles, child) {
            if (profiles.isEmpty) {
              return const Text('멤버가 없습니다.');
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final user = profiles[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        user.accountName![0].toUpperCase(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Text(user.accountName ?? 'null'),
                  );
                },
              ),
            );
          },
        ),
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

// 메세지 형태
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int senderId;
  final bool isCurrentUser;
  final VoidCallback onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.senderId,
    required this.isCurrentUser,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 내 메시지인지 여부에 따라 색상 설정
    final bubbleColor = isCurrentUser ? Colors.blue[100] : Colors.green[100];

    return GestureDetector(
      onLongPress: isCurrentUser ? onDelete : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          // 내 메시지면 왼쪽, 상대방 메시지면 오른쪽 정렬
          mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 아바타 위치도 변경
            if (isCurrentUser) _buildAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          senderId.toString(),
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
            if (!isCurrentUser) _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.grey[300],
      radius: 16,
      child: Text(
        senderId.toString(),
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