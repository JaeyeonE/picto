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
      // WebSocket 연결 초기화
      await sessionService.initializeWebSocket(sessionId);
      await sessionService.enterSession(sessionId);
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
        (message) => messages.add(message),
        onError: (error) => print('Error in session message stream: $error'),
        onDone: () {
          print('Session stream closed');
          isInSession.value = false;
          // 필요한 경우 재연결 로직 추가
        },
      );
    }
  }

  Future<void> sendLocation(double lat, double lng) async {
    if (!isInSession.value) return;
    
    try {
      await sessionService.sendLocation(sessionId, lat, lng);
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  Future<void> _exitSession() async {
    if (!isInSession.value) return;
    
    try {
      await sessionService.exitSession(sessionId);
      isInSession.value = false;
    } catch (e) {
      print('Error exiting session: $e');
    }
  }
}