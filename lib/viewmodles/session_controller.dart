import 'package:flutter/material.dart';
import 'dart:async';
import 'package:picto/models/session.dart';
import 'package:picto/services/session/session_service.dart';


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
    } catch (e) {
      print('세션 초기화 오류: $e');
      _handleError(e);
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

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
    if (_isConnecting) return;

    await Future.delayed(const Duration(seconds: 5));
    if (!isConnected && !_isConnecting) {
      await _initializeSession();
    }
  }
}