import 'package:get/get.dart';
import '../services/session_service.dart';
import '../models/common/session_message.dart';

class SessionController extends GetxController {
  final SessionService sessionService;
  final int sessionId;

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
      stream.listen(
        (message) {
          messages.add(message);
          // 메시지 타입에 따른 상태 업데이트
          if (message.messageType == 'EXIT') {
            isInSession.value = false;
          }
        },
        onError: (error) {
          print('Error in session message stream: $error');
          isInSession.value = false;
        },
        onDone: () {
          print('Session stream closed');
          isInSession.value = false;
          _tryReconnect();
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
      await _initializeSession();
    }
  }
}