import 'package:get/get.dart';
import '../services/session_service.dart';
import '../models/common/session_message.dart';

class SessionController extends GetxController {
  final SessionService _sessionService = SessionService();
  final String sessionId;
  final String currentUserId;

  final RxList<SessionMessage> messages = <SessionMessage>[].obs;
  final RxBool isInSession = false.obs;

  SessionController({
    required this.sessionId,
    required this.currentUserId,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeSession();
  }

  @override
  void onClose() {
    _exitSession();
    _sessionService.dispose();
    super.onClose();
  }

  Future<void> _initializeSession() async {
    try {
      await _sessionService.enterSession(currentUserId);
      isInSession.value = true;
      _startMessageStream();
    } catch (e) {
      print('Error initializing session: $e');
    }
  }

  void _startMessageStream() {
    _sessionService.getSessionMessages(sessionId).listen(
      (message) {
        messages.add(message);
      },
      onError: (error) {
        print('Error in message stream: $error');
      },
    );
  }

  Future<void> sendLocation(double lat, double lng) async {
    try {
      await _sessionService.sendLocation(currentUserId, lat, lng);
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  Future<void> _exitSession() async {
    try {
      await _sessionService.exitSession(currentUserId);
      isInSession.value = false;
    } catch (e) {
      print('Error exiting session: $e');
    }
  }
}