import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/folder/chat_message_model.dart';
import '../models/folder/status_model.dart';

class ChatService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://HOST/chatting-scheduler';
  
  // 채팅방 메시지 목록 조회
  Future<List<ChatMessage>> getMessages(String folderId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/folder/$folderId',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  // 채팅방 입장
  Future<void> enterChat(String folderId, String senderId) async {
    try {
      await _dio.post(
        '$baseUrl/send/chat/enter',
        data: {
          'senderId': senderId,
          'folderId': folderId,
          'messageType': 'ENTER',
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error entering chat: $e');
    }
  }

  // 채팅방 퇴장
  Future<void> leaveChat(String folderId, String senderId) async {
    try {
      await _dio.post(
        '$baseUrl/send/chat/leave',
        data: {
          'senderId': senderId,
          'folderId': folderId,
          'messageType': 'EXIT',
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error leaving chat: $e');
    }
  }

  // 메시지 전송
  Future<void> sendMessage(String folderId, String senderId, String content) async {
    try {
      await _dio.post(
        '$baseUrl/send/chat/message',
        data: {
          'senderId': senderId,
          'folderId': folderId,
          'messageType': 'MESSAGE',
          'content': content,
          'sendDateTime': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // 채팅방 참여자 목록 조회
  Future<List<String>> getChatMembers(String folderId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/folder/$folderId/cheator',
      );
      
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        throw Exception('Failed to load chat members');
      }
    } catch (e) {
      throw Exception('Error fetching chat members: $e');
    }
  }
}