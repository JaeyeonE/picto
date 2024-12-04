import 'package:get/get.dart';
import '../services/session_service.dart';
import '../models/common/session_message.dart';
import 'chat_view_model.dart';

class SessionController extends GetxController {
  final SessionService sessionService;  // private에서 public으로 변경
  final int sessionId;

  final RxList<SessionMessage> messages = <SessionMessage>[].obs;  // 타입 명시
  final RxBool isInSession = false.obs;

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
    try {
      await sessionService.enterSession(sessionId);
      isInSession.value = true;
      _startMessageStream();
    } catch (e) {
      print('Error initializing session: $e');
    }
  }

  void _startMessageStream() {
    sessionService.getSessionMessages(sessionId).listen(
      (message) => messages.add(message),
      onError: (error) => print('Error in message stream: $error'),
    );
  }

  Future<void> sendLocation(double lat, double lng) async {
    try {
      await sessionService.sendLocation(sessionId, lat, lng);
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  Future<void> _exitSession() async {
    try {
      await sessionService.exitSession(sessionId);
      isInSession.value = false;
    } catch (e) {
      print('Error exiting session: $e');
    }
  }
}