// import 'package:flutter/foundation.dart';

// import 'package:picto/models/folder/chat_model.dart';
// import 'package:picto/services/chat_service.dart';

// class ChatViewModel extends ChangeNotifier {
//   final ChatService _chatService;
//   List<ChatMessage> _messages = [];
//   String _currentFolderName = '';
//   bool _isLoading = false;

//   ChatViewModel(this._chatService);

//   List<ChatMessage> get messages => _messages;
//   bool get isLoading => _isLoading;

//   void setCurrentFolder(String folderName) {
//     _currentFolderName = folderName;
//     _listenToMessages();
//   }

//   void _listenToMessages() {
//     _chatService.getChatMessages(_currentFolderName).listen((updatedMessages) {
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
//     } catch (e) {
//       print('Error sending message: $e');
//     }
//   }
// }