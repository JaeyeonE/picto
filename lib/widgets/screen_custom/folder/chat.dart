import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import 'package:picto/viewmodles/chat_view_model.dart';


class Chat extends StatefulWidget{
  const Chat({super.key});
  
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context){
    return Consumer<ChatViewModel> (
      builder: (context, viewmodel, child){
        return Scaffold(
          body: const Text('hello world'),
        );
      }
    );
  }
}