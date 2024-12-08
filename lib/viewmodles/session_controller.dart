import 'package:flutter/material.dart';
import 'dart:async';
import '../services/session_service.dart';
import '../models/common/session_message.dart';

class SessionController extends ChangeNotifier {
  final SessionService sessionService;
  final int sessionId;
  StreamSubscription? _sessionSubscription;

  List<SessionMessage> _messages = [];
  bool _isInSession = false;
  bool _isConnecting = false;

  SessionController({
    required this.sessionId,
  }) : sessionService = SessionService() {
    _initializeSession();
  }

  // Getters
  List<SessionMessage> get messages => _messages;
  bool get isInSession => _isInSession;
  bool get isConnecting => _isConnecting;

  @override
  void dispose() {
    _exitSession();
    _sessionSubscription?.cancel();
    sessionService.dispose();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    _isConnecting = true;
    notifyListeners();

    try {
      await sessionService.initializeWebSocket(sessionId);
      sessionService.enterSession(sessionId);
      _isInSession = true;
      _startMessageStream();
    } catch (e) {
      print('Error initializing session: $e');
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void _startMessageStream() {
    final stream = sessionService.getSessionStream();
    if (stream != null) {
      _sessionSubscription?.cancel();
      _sessionSubscription = stream.listen(
        (message) {
          _messages.add(message);
          if (message.messageType == 'EXIT') {
            _isInSession = false;
          }
          notifyListeners();
        },
        onError: (error) {
          print('Error in session message stream: $error');
          _isInSession = false;
          notifyListeners();
        },
        onDone: () {
          print('Session stream closed');
          _isInSession = false;
          notifyListeners();
        },
      );
    }
  }

  void sendLocation(double lat, double lng) {
    if (!_isInSession || !sessionService.isConnected) return;
    
    try {
      sessionService.sendLocation(sessionId, lat, lng);
    } catch (e) {
      print('Error sending location: $e');
      _tryReconnect();
    }
  }

  void _exitSession() {
    if (!_isInSession || !sessionService.isConnected) return;
    
    try {
      sessionService.exitSession(sessionId);
      _isInSession = false;
      notifyListeners();
    } catch (e) {
      print('Error exiting session: $e');
    }
  }

  Future<void> _tryReconnect() async {
    if (!_isInSession && !_isConnecting) {
      await Future.delayed(const Duration(seconds: 5));
      if (!_isInSession && !_isConnecting) {
        await _initializeSession();
      }
    }
  }
}