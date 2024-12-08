// lib/services/session/websocket_logging_interceptor.dart

class WebSocketLoggingInterceptor {
  void onConnect(String url, Map<String, dynamic>? headers) {
    print('=== WebSocket Connect ===');
    print('URL: $url');
    print('Headers: $headers');
    print('=======================');
  }

  void onSubscribe(String destination) {
    print('=== WebSocket Subscribe ===');
    print('Destination: $destination');
    print('=========================');
  }

  void onSend(String destination, String body) {
    print('=== WebSocket Send ===');
    print('Destination: $destination');
    print('Body: $body');
    print('===================');
  }

  void onMessage(String destination, String body) {
    print('=== WebSocket Message ===');
    print('From: $destination');
    print('Body: $body');
    print('======================');
  }

  void onError(dynamic error) {
    print('=== WebSocket Error ===');
    print('Error: $error');
    print('====================');
  }

  void onDisconnect() {
    print('=== WebSocket Disconnect ===');
    print('==========================');
  }
}