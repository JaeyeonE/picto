import 'dart:async';

class WebSocketConnectionManager {
  static const int maxReconnectAttempts = 3;
  static const Duration initialDelay = Duration(seconds: 2);
  static const Duration maxDelay = Duration(seconds: 30);
  
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool isReconnecting = false;

  Duration _getNextDelay() {
    // 지수 백오프: 2초, 4초, 8초, 16초... 최대 30초
    final delay = initialDelay * (1 << _reconnectAttempts);
    return delay > maxDelay ? maxDelay : delay;
  }

  Future<void> reconnect(Future<void> Function() connectFunc) async {
    if (isReconnecting) {
      print('Reconnection already in progress');
      return;
    }

    isReconnecting = true;
    
    while (_reconnectAttempts < maxReconnectAttempts) {
      try {
        final delay = _getNextDelay();
        print('Attempting to reconnect in ${delay.inSeconds} seconds (Attempt ${_reconnectAttempts + 1}/$maxReconnectAttempts)');
        
        await Future.delayed(delay);
        await connectFunc();
        
        print('Reconnection successful');
        _resetReconnectionState();
        return;
      } catch (e) {
        print('Reconnection attempt ${_reconnectAttempts + 1} failed: $e');
        _reconnectAttempts++;
        
        if (_reconnectAttempts >= maxReconnectAttempts) {
          print('Max reconnection attempts reached');
          _resetReconnectionState();
          rethrow;
        }
      }
    }
  }

  void _resetReconnectionState() {
    _reconnectAttempts = 0;
    isReconnecting = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void dispose() {
    _resetReconnectionState();
  }
}