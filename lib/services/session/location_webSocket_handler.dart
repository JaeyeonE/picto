import 'dart:async';
import 'package:picto/services/session/session_service.dart';

class LocationWebSocketHandler {
  final SessionService _sessionService;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;

  LocationWebSocketHandler(this._sessionService);

  Future<void> sendLocationWithRetry({
    required int userId,
    required double latitude,
    required double longitude,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        if (!_sessionService.isConnected) {
          await _reconnectWebSocket(userId);
        }

        await _sessionService.sendLocation(userId, latitude, longitude);
        return; // 성공하면 종료
      } on SessionServiceException catch (e) {
        if (e.code == 'NOT_CONNECTED') {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }
        rethrow;
      } catch (e) {
        rethrow;
      }
    }

    throw SessionServiceException('위치 전송 재시도 횟수 초과');
  }

  Future<void> _reconnectWebSocket(int userId) async {
    if (_isReconnecting) return;
    _isReconnecting = true;

    try {
      await _sessionService.initializeWebSocket(userId);
      await _sessionService.enterSession(userId);
      _isReconnecting = false;
    } catch (e) {
      _isReconnecting = false;
      throw SessionServiceException('웹소켓 재연결 실패: $e');
    }
  }

  void dispose() {
    _reconnectTimer?.cancel();
  }
}