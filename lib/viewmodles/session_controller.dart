import 'dart:async';

import 'package:get/get.dart';
import '../services/session_service.dart';
import '../models/common/session_message.dart';


class SessionController extends GetxController {
  final SessionService sessionService;
  final int sessionId;
  StreamSubscription? _sessionSubscription;

  final RxList<SessionMessage> messages = <SessionMessage>[].obs;
  final RxBool isInSession = false.obs;
  final RxBool isConnecting = false.obs;

  SessionController({
    required this.sessionId,
  }) : sessionService = SessionService();

  @override
  void onInit() {
    super.onInit();
    _initializeSession();
  }

  @override
  void onClose() {
    _exitSession();
    _sessionSubscription?.cancel();  // 구독 취소
    sessionService.dispose();
    super.onClose();
  }

  Future<void> _initializeSession() async {
    isConnecting.value = true;
    try {
      await sessionService.initializeWebSocket(sessionId);
      sessionService.enterSession(sessionId);
      isInSession.value = true;
      _startMessageStream();
    } catch (e) {
      print('Error initializing session: $e');
    } finally {
      isConnecting.value = false;
    }
  }

  void _startMessageStream() {
    final stream = sessionService.getSessionStream();
    if (stream != null) {
      _sessionSubscription?.cancel();  // 기존 구독 취소
      _sessionSubscription = stream.listen(
        (message) {
          messages.add(message);
          if (message.messageType == 'EXIT') {
            isInSession.value = false;
          }
        },
        onError: (error) {
          print('Error in session message stream: $error');
          isInSession.value = false;
          // 즉시 재연결하지 않음
        },
        onDone: () {
          print('Session stream closed');
          isInSession.value = false;
          // 즉시 재연결하지 않음
        },
      );
    }
  }

  void sendLocation(double lat, double lng) {
    if (!isInSession.value || !sessionService.isConnected) return;
    
    try {
      sessionService.sendLocation(sessionId, lat, lng);
    } catch (e) {
      print('Error sending location: $e');
      _tryReconnect();
    }
  }

  void _exitSession() {
    if (!isInSession.value || !sessionService.isConnected) return;
    
    try {
      sessionService.exitSession(sessionId);
      isInSession.value = false;
    } catch (e) {
      print('Error exiting session: $e');
    }
  }

  Future<void> _tryReconnect() async {
    if (!isInSession.value && !isConnecting.value) {
      await Future.delayed(const Duration(seconds: 5));  // 재연결 전 딜레이
      if (!isInSession.value && !isConnecting.value) {  // 상태 재확인
        await _initializeSession();
      }
    }
  }
}