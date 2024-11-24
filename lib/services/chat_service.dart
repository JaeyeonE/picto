// // services/chat_service.dart
// import 'package:dio/dio.dart';

// import 'package:flutter/material.dart';
// import 'package:picto/models/folder/chat_model.dart';

// class ChatService {
//   final Dio _dio = Dio();

//   // 특정 폴더의 메시지 목록 조회
//   Future<List<ChatMessage>> getChatMessages(String folderName) async {
//     try {
//       final response = await _dio.get('/chats', 
//         queryParameters: {'folderName': folderName}
//       );
      
//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data['messages'];
//         return data.map((json) => ChatMessage.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load messages');
//       }
//     } catch (e) {
//       throw Exception('Error fetching messages: $e');
//     }
//   }

//   // 새 메시지 전송
//   Future<void> sendMessage(ChatMessage message) async {
//     try {
//       await _dio.post('/chats/send',
//         data: message.toJson(),
//       );
//     } catch (e) {
//       throw Exception('Error sending message: $e');
//     }
//   }

//   // 실시간 메시지 업데이트를 위한 폴링 메서드
//   Stream<List<ChatMessage>> streamMessages(String folderName) async* {
//     while (true) {
//       try {
//         final messages = await getChatMessages(folderName);
//         yield messages;
//         await Future.delayed(const Duration(seconds: 2)); // 폴링 간격
//       } catch (e) {
//         print('Error in message stream: $e');
//         await Future.delayed(const Duration(seconds: 5)); // 에러 시 더 긴 대기
//       }
//     }
//   }
// }

// // viewmodels/chat_view_model.dart
// class ChatViewModel extends ChangeNotifier {
//   final ChatService _chatService;
//   List<ChatMessage> _messages = [];
//   String _currentFolderName = '';
//   bool _isLoading = false;
//   StreamSubscription? _messageSubscription;

//   ChatViewModel(this._chatService);

//   List<ChatMessage> get messages => _messages;
//   bool get isLoading => _isLoading;

//   void setCurrentFolder(String folderName) {
//     _currentFolderName = folderName;
//     _loadInitialMessages();
//     _startMessageStream();
//   }

//   Future<void> _loadInitialMessages() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final messages = await _chatService.getChatMessages(_currentFolderName);
//       _messages = messages;
      
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//       print('Error loading messages: $e');
//     }
//   }

//   void _startMessageStream() {
//     _messageSubscription?.cancel();
//     _messageSubscription = _chatService
//         .streamMessages(_currentFolderName)
//         .listen((updatedMessages) {
//       _messages = updatedMessages;
//       notifyListeners();
//     });
//   }

//   Future<void> sendMessage(String content, String senderId) async {
//     try {
//       final message = ChatMessage(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         senderId: senderId,
//         message: content,
//         timestamp: DateTime.now(),
//         folderName: _currentFolderName,
//       );
      
//       await _chatService.sendMessage(message);
//       // 메시지 전송 후 즉시 목록 갱신
//       await _loadInitialMessages();
//     } catch (e) {
//       print('Error sending message: $e');
//       // 에러 처리 로직 추가 가능
//     }
//   }

//   @override
//   void dispose() {
//     _messageSubscription?.cancel();
//     super.dispose();
//   }
// }

// // views/chat_view.dart는 이전과 동일하나, 로딩 상태 표시를 추가

// class ChatViewContent extends StatelessWidget {
//   final String currentUserId;

//   ChatViewContent({required this.currentUserId});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ChatViewModel>(
//       builder: (context, viewModel, child) {
//         if (viewModel.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final messages = viewModel.messages.map((msg) {
//           return types.TextMessage(
//             id: msg.id,
//             author: types.User(id: msg.senderId),
//             text: msg.message,
//             createdAt: msg.timestamp.millisecondsSinceEpoch,
//           );
//         }).toList();

//         return Scaffold(
//           appBar: AppBar(
//             title: Text('Chat'),
//           ),
//           body: Chat(
//             messages: messages,
//             onSendPressed: (types.PartialText message) {
//               viewModel.sendMessage(
//                 message.text,
//                 currentUserId,
//               );
//             },
//             user: types.User(id: currentUserId),
//           ),
//         );
//       },
//     );
//   }
// }