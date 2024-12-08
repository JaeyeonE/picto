import 'dart:async';
import 'dart:convert';
import 'package:picto/models/session.dart';
import 'package:picto/services/websocket_logging_interceptor.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class SessionService {
  static const int maxReconnectAttempts = 3;
  static const Duration reconnectDelay = Duration(seconds: 5);

  final WebSocketLoggingInterceptor _logger = WebSocketLoggingInterceptor();
  StompClient? _stompClient;
  StreamController<SessionMessage>? _messageController;
  StreamController<WebSocketStatus>? _statusController;
  Completer<void>? _connectionCompleter;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int? _currentSessionId;
  int _reconnectAttempts = 0;
  bool _isReconnecting = false;

  SessionService() {
    _messageController = StreamController<SessionMessage>.broadcast();
    _statusController = StreamController<WebSocketStatus>.broadcast();
    print('세션 서비스가 초기화되었습니다');
  }

  Future<void> initializeWebSocket(int sessionId) async {
    print('세션 ID: $sessionId에 대한 웹소켓 초기화 중');
    _currentSessionId = sessionId;
    _connectionCompleter = Completer<void>();
    await _connectWebSocket();

    // 연결이 완료될 때까지 대기
    try {
      await _connectionCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw SessionServiceException('웹소켓 연결 시간 초과',
              code: 'CONNECTION_TIMEOUT');
        },
      );
    } catch (e) {
      print('웹소켓 초기화 실패: $e');
      rethrow;
    }
  }

  Future<void> _connectWebSocket() async {
    if (_currentSessionId == null) return;

    final url = 'http://52.79.109.62:8085/session-scheduler';
    try {
      _stompClient?.deactivate();
      _logger.onConnect(url, null);

      _stompClient = StompClient(
        config: StompConfig.sockJS(
          url: url,
          onConnect: _onConnect,
          beforeConnect: () async {
            // Future<void>를 명시적으로 반환
            _logger.onConnect(url, null);
            return; // 또는 return Future<void>.value();
          },
          onWebSocketError: (dynamic error) {
            _logger.onError(error);
            _handleConnectionError();
          },
          onDisconnect: (_) {
            _logger.onDisconnect();
            _isConnected = false;
            _statusController?.add(WebSocketStatus.disconnected);
          },
          onStompError: (frame) {
            _logger.onError('STOMP 오류: ${frame.body}');
          },
        ),
      );

      _stompClient?.activate();
    } catch (e) {
      _logger.onError('세션 웹소켓 연결 실패: $e');
      _isConnected = false;
      _handleConnectionError();
    }
  }

  void _onConnect(StompFrame frame) {
    print('연결됨: ${frame.body}');
    _isConnected = true;
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _setupHeartbeat();
    _statusController?.add(WebSocketStatus.connected);

    // 세션 메시지 구독
    final destination = '/session/${_currentSessionId}';
    _logger.onSubscribe(destination);

    _stompClient?.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            _logger.onMessage(destination, frame.body!);
            final jsonData = jsonDecode(frame.body!);
            final message = SessionMessage.fromJson(jsonData);
            _messageController?.add(message);
          }
        } catch (e) {
          _logger.onError('세션 메시지 파싱 오류: $e');
        }
      },
    );

    print('세션 구독 성공');

    // 연결 완료 알림
    _connectionCompleter?.complete();
  }

  void _handleConnectionError() {
    if (_isReconnecting) return;

    _isConnected = false;
    _statusController?.add(WebSocketStatus.disconnected);

    // 연결 실패 알림
    if (!(_connectionCompleter?.isCompleted ?? true)) {
      _connectionCompleter?.completeError(
          SessionServiceException('웹소켓 연결 실패', code: 'CONNECTION_FAILED'));
    }
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _logger.onError('최대 재연결 시도 횟수 도달');
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    print(
        '$_reconnectAttempts/$maxReconnectAttempts 번째 재연결 시도 중... ${reconnectDelay.inSeconds}초 후 시도합니다.');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () async {
      try {
        await _connectWebSocket();
      } catch (e) {
        _logger.onError('재연결 시도 실패: $e');
        _handleConnectionError();
      }
    });
  }

  void _setupHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        try {
          final message = {
            'type': 'PING',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          };
          final destination = '/send/session/ping';
          final body = jsonEncode(message);

          _logger.onSend(destination, body);
          _stompClient?.send(
            destination: destination,
            body: body,
          );
        } catch (e) {
          _logger.onError('세션 하트비트 실패: $e');
          _handleConnectionError();
        }
      }
    });
  }

  Future<void> sendLocation(int senderId, double lat, double lng) async {
    print('위치 전송 중 - 사용자: $senderId, 위도: $lat, 경도: $lng');
    _validateConnection();

    try {
      final message = SessionMessage(
        type: 'LOCATION',
        senderId: senderId,
        lat: lat,
        lng: lng,
        sendDateTime: DateTime.now().toUtc().toIso8601String(),
      );

      final destination = '/send/session/location';
      final body = jsonEncode(message.toJson());

      _logger.onSend(destination, body);
      _stompClient?.send(
        destination: destination,
        body: body,
      );
      print('위치 전송 성공');
    } catch (e) {
      _logger.onError('위치 전송 실패: $e');
      throw SessionServiceException('위치 전송 실패: ${e.toString()}');
    }
  }

  Future<void> sharePhoto(
      int senderId, int photoId, double lat, double lng) async {
    print('사진 공유 중 - 사용자: $senderId, 사진ID: $photoId, 위도: $lat, 경도: $lng');
    _validateConnection();

    try {
      final message = SessionMessage(
        type: 'SHARE',
        senderId: senderId,
        photoId: photoId,
        lat: lat,
        lng: lng,
        sendDateTime: DateTime.now().toUtc().toIso8601String(),
      );

      final destination = '/send/session/shared';
      final body = jsonEncode(message.toJson());

      _logger.onSend(destination, body);
      _stompClient?.send(
        destination: destination,
        body: body,
      );
      print('사진 공유 성공');
    } catch (e) {
      _logger.onError('사진 공유 실패: $e');
      throw SessionServiceException('사진 공유 실패: ${e.toString()}');
    }
  }

  // enterSession 메서드 수정
  Future<void> enterSession(int senderId) async {
    print('사용자 세션 입장 시도: $senderId');
    
    // 연결이 아직 진행 중이라면 완료될 때까지 대기
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      print('웹소켓 연결 대기 중...');
      await _connectionCompleter!.future;
    }
    
    _validateConnection();

    try {
      final message = SessionMessage(
        type: 'ENTER',
        senderId: senderId,
        sendDateTime: DateTime.now().toUtc().toIso8601String(),
      );

      final destination = '/send/session/enter';
      final body = jsonEncode(message.toJson());

      _logger.onSend(destination, body);
      _stompClient?.send(
        destination: destination,
        body: body,
      );
      print('세션 입장 성공');
    } catch (e) {
      _logger.onError('세션 입장 실패: $e');
      throw SessionServiceException('세션 입장 실패: ${e.toString()}');
    }
  }

  Future<void> exitSession(int senderId) async {
    print('사용자 세션 퇴장: $senderId');
    _validateConnection();

    try {
      final message = SessionMessage(
        type: 'EXIT',
        senderId: senderId,
        sendDateTime: DateTime.now().toUtc().toIso8601String(),
      );

      final destination = '/send/session/exit';
      final body = jsonEncode(message.toJson());

      _logger.onSend(destination, body);
      _stompClient?.send(
        destination: destination,
        body: body,
      );
      print('세션 퇴장 성공');
    } catch (e) {
      _logger.onError('세션 퇴장 실패: $e');
      throw SessionServiceException('세션 퇴장 실패: ${e.toString()}');
    }
  }

  void _validateConnection() {
    if (!_isConnected) {
      throw SessionServiceException('웹소켓이 연결되지 않았습니다', code: 'NOT_CONNECTED');
    }
  }

  Stream<SessionMessage> getSessionStream() => _messageController!.stream;
  Stream<WebSocketStatus> getStatusStream() => _statusController!.stream;
  bool get isConnected => _isConnected;

  @override
  void dispose() {
    print('세션 서비스 정리 중');
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _stompClient?.deactivate();
    _messageController?.close();
    _statusController?.close();
    _isConnected = false;
    // Completer 정리
    if (!(_connectionCompleter?.isCompleted ?? true)) {
      _connectionCompleter?.completeError(
        SessionServiceException('서비스가 종료됨', code: 'SERVICE_DISPOSED')
      );
    }
    _connectionCompleter = null;
  }
}

// SessionServiceException 클래스
class SessionServiceException implements Exception {
  final String message;
  final String? code;

  /// 세션 서비스 예외를 생성합니다.
  /// [message]는 예외 메시지입니다.
  /// [code]는 선택적 에러 코드입니다.
  SessionServiceException(this.message, {this.code});

  @override
  String toString() =>
      'SessionServiceException: $message${code != null ? ' (코드: $code)' : ''}';
}
