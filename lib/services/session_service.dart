




// import 'dart:async';
// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../models/common/session_message.dart';
// import '../models/common/websocket_status.dart';

// class SessionServiceException implements Exception {
//   final String message;
//   final String? code;
//   SessionServiceException(this.message, {this.code});
//   @override
//   String toString() => 'SessionServiceException: $message${code != null ? ' (Code: $code)' : ''}';
// }

// class SessionService {
//   static const int maxReconnectAttempts = 3;
//   static const Duration reconnectDelay = Duration(seconds: 5);
  
//   WebSocketChannel? _channel;
//   Stream<SessionMessage>? _messageStream;
//   bool _isConnected = false;
//   Timer? _heartbeatTimer;
//   Timer? _reconnectTimer;
//   StreamController<WebSocketStatus>? _statusController;
//   int? _currentSessionId;
//   int _reconnectAttempts = 0;
//   bool _isReconnecting = false;

//   SessionService() {
//     _statusController = StreamController<WebSocketStatus>.broadcast();
//     print('SessionService initialized');
//   }

//   Future<void> initializeWebSocket(int sessionId) async {
//     print('Initializing Session WebSocket for session: $sessionId');
//     _currentSessionId = sessionId;
//     await _connectWebSocket();
//   }

//   Future<void> _connectWebSocket() async {
//     if (_currentSessionId == null) return;
    
//     final wsUrl = Uri(
//       scheme: 'ws',
//       host: '52.79.109.62',
//       port: 8085,
//       path: '/session-scheduler/session/$_currentSessionId'
//     );

//     try {
//       await _channel?.sink.close();
//       _channel = WebSocketChannel.connect(wsUrl);
      
//       _messageStream = _channel?.stream.map((data) {
//         try {
//           final jsonData = jsonDecode(data);
//           return SessionMessage.fromJson(jsonData);
//         } catch (e) {
//           print('Error parsing session message: $e');
//           throw SessionServiceException('Invalid message format', code: 'PARSE_ERROR');
//         }
//       }).handleError((error) {
//         print('Session stream error: $error');
//         _handleConnectionError();
//       });

//       _isConnected = true;
//       _reconnectAttempts = 0;
//       _isReconnecting = false;
//       _setupHeartbeat();
//       _statusController?.add(WebSocketStatus.connected);
//       print('Session WebSocket connected to: $wsUrl');
      
//     } catch (e) {
//       print('Session WebSocket connection failed: $e');
//       _isConnected = false;
//       _handleConnectionError();
//     }
//   }

//   void _handleConnectionError() {
//     if (_isReconnecting) return;
    
//     _isConnected = false;
//     _statusController?.add(WebSocketStatus.disconnected);
    
//     if (_reconnectAttempts >= maxReconnectAttempts) {
//       print('Max reconnection attempts reached');
//       return;
//     }

//     _isReconnecting = true;
//     _reconnectAttempts++;
    
//     print('Attempting to reconnect in ${reconnectDelay.inSeconds} seconds (Attempt $_reconnectAttempts/$maxReconnectAttempts)');
    
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(reconnectDelay, () async {
//       try {
//         await _connectWebSocket();
//       } catch (e) {
//         print('Reconnection attempt failed: $e');
//         _handleConnectionError();
//       }
//     });
//   }

//   void _setupHeartbeat() {
//     _heartbeatTimer?.cancel();
//     _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (_isConnected) {
//         try {
//           _channel?.sink.add(jsonEncode({
//             'type': 'PING',
//             'timestamp': DateTime.now().toUtc().toIso8601String(),
//           }));
//         } catch (e) {
//           print('Session heartbeat failed: $e');
//           _handleConnectionError();
//         }
//       }
//     });
//   }

//   Future<void> sendLocation(int senderId, double lat, double lng) async {
//     print('Sending location - User: $senderId, Lat: $lat, Lng: $lng');
//     _validateConnection();

//     try {
//       final message = {
//         'type': 'LOCATION',
//         'senderId': senderId,
//         'lat': lat,
//         'lng': lng,
//         'sendDateTime': DateTime.now().toUtc().toIso8601String(),
//       };
//       _channel?.sink.add(jsonEncode(message));
//       print('Location sent successfully');
//     } catch (e) {
//       print('Failed to send location: $e');
//       throw SessionServiceException('Failed to send location: ${e.toString()}');
//     }
//   }

//   Future<void> enterSession(int senderId) async {
//     print('User entering session: $senderId');
//     _validateConnection();

//     try {
//       final message = {
//         'type': 'ENTER',
//         'senderId': senderId,
//         'sendDateTime': DateTime.now().toUtc().toIso8601String(),
//       };
//       _channel?.sink.add(jsonEncode(message));
//       print('Successfully entered session');
//     } catch (e) {
//       print('Failed to enter session: $e');
//       throw SessionServiceException('Failed to enter session: ${e.toString()}');
//     }
//   }

//   Future<void> exitSession(int senderId) async {
//     print('User exiting session: $senderId');
//     _validateConnection();

//     try {
//       final message = {
//         'type': 'EXIT',
//         'senderId': senderId,
//         'sendDateTime': DateTime.now().toUtc().toIso8601String(),
//       };
//       _channel?.sink.add(jsonEncode(message));
//       print('Successfully exited session');
//     } catch (e) {
//       print('Failed to exit session: $e');
//       throw SessionServiceException('Failed to exit session: ${e.toString()}');
//     }
//   }

//   void _validateConnection() {
//     if (!_isConnected) {
//       throw SessionServiceException('WebSocket not connected', code: 'NOT_CONNECTED');
//     }
//   }

//   Stream<SessionMessage>? getSessionStream() => _messageStream;
//   Stream<WebSocketStatus>? getStatusStream() => _statusController?.stream;
//   bool get isConnected => _isConnected;

//   void dispose() {
//     print('Disposing SessionService');
//     _heartbeatTimer?.cancel();
//     _reconnectTimer?.cancel();
//     _channel?.sink.close();
//     _messageStream = null;
//     _isConnected = false;
//     _statusController?.close();
//   }
// }