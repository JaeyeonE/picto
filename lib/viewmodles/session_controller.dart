import 'dart:async';
<<<<<<< HEAD
import 'package:picto/models/session.dart';
import 'package:picto/services/session_service.dart';


class SessionController extends ChangeNotifier {
  final SessionService _sessionService;
  final int _sessionId;
  final int _userId;
  StreamSubscription<SessionMessage>? _messageSubscription;
  StreamSubscription<WebSocketStatus>? _statusSubscription;

  List<SessionMessage> _messages = [];
  bool _isInSession = false;
  bool _isConnecting = false;
  WebSocketStatus _connectionStatus = WebSocketStatus.disconnected;

  SessionController({
    required int sessionId,
    required int userId,
  }) : _sessionId = sessionId,
       _userId = userId,
       _sessionService = SessionService() {
    _initializeSession();
  }

  // Getters
  List<SessionMessage> get messages => List.unmodifiable(_messages);
  bool get isInSession => _isInSession;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _connectionStatus == WebSocketStatus.connected;

  @override
  void dispose() {
    _cleanupSession();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    if (_isConnecting) return;

    _isConnecting = true;
    notifyListeners();

    try {
      await _sessionService.initializeWebSocket(_sessionId);
      _setupSubscriptions();
      await _sessionService.enterSession(_userId);
      _isInSession = true;
=======

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
>>>>>>> main
    } catch (e) {
      print('세션 초기화 오류: $e');
      _handleError(e);
    } finally {
      isConnecting.value = false;
    }
  }

<<<<<<< HEAD
  void _setupSubscriptions() {
    // 메시지 스트림 구독
    _messageSubscription = _sessionService.getSessionStream().listen(
      (message) {
        _handleMessage(message);
      },
      onError: (error) {
        print('세션 메시지 스트림 오류: $error');
        _handleError(error);
      },
    );

    // 상태 스트림 구독
    _statusSubscription = _sessionService.getStatusStream().listen(
      (status) {
        _handleStatusChange(status);
      },
      onError: (error) {
        print('웹소켓 상태 스트림 오류: $error');
        _handleError(error);
      },
    );
  }

  void _handleMessage(SessionMessage message) {
    _messages.add(message);
=======
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
>>>>>>> main
    
    if (message.type == 'EXIT' && message.senderId == _userId) {
      _isInSession = false;
    }
    
    notifyListeners();
  }

  void _handleStatusChange(WebSocketStatus status) {
    _connectionStatus = status;
    
    if (status == WebSocketStatus.disconnected && _isInSession) {
      _tryReconnect();
    }
    
    notifyListeners();
  }

<<<<<<< HEAD
  void _handleError(dynamic error) {
    if (error is SessionServiceException) {
      if (error.code == 'NOT_CONNECTED' || error.code == 'CONNECTION_FAILED') {
        _tryReconnect();
      }
    }
    _isInSession = false;
    notifyListeners();
  }

  Future<void> sendLocation(double lat, double lng) async {
    if (!isConnected || !_isInSession) return;

    try {
      await _sessionService.sendLocation(_userId, lat, lng);
    } catch (e) {
      print('위치 전송 오류: $e');
      _handleError(e);
    }
  }

  Future<void> sharePhoto(int photoId, double lat, double lng) async {
    if (!isConnected || !_isInSession) return;

    try {
      await _sessionService.sharePhoto(_userId, photoId, lat, lng);
    } catch (e) {
      print('사진 공유 오류: $e');
      _handleError(e);
    }
  }

  Future<void> exitSession() async {
    if (!isConnected || !_isInSession) return;

    try {
      await _sessionService.exitSession(_userId);
      _isInSession = false;
      notifyListeners();
=======
  void _exitSession() {
    if (!isInSession.value || !sessionService.isConnected) return;
    
    try {
      sessionService.exitSession(sessionId);
      isInSession.value = false;
>>>>>>> main
    } catch (e) {
      print('세션 퇴장 오류: $e');
      _handleError(e);
    }
  }

  void _cleanupSession() {
    _isInSession = false;
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _sessionService.dispose();
  }

  Future<void> _tryReconnect() async {
<<<<<<< HEAD
    if (_isConnecting) return;

    await Future.delayed(const Duration(seconds: 5));
    if (!isConnected && !_isConnecting) {
      await _initializeSession();
=======
    if (!isInSession.value && !isConnecting.value) {
      await Future.delayed(const Duration(seconds: 5));  // 재연결 전 딜레이
      if (!isInSession.value && !isConnecting.value) {  // 상태 재확인
        await _initializeSession();
      }
>>>>>>> main
    }
  }
}