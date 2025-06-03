// frontend/lib/services/chat_service.dart
import 'dart:async';
import 'package:flutter/material.dart'; // VoidCallback을 위해 필요
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  // 메시지 중복 방지를 위한 Set
  final Set<String> _receivedMessageIds = <String>{};

  // 메시지 전송 중복 방지를 위한 Map
  final Map<String, bool> _sendingMessages = <String, bool>{};

  // 콜백 함수들을 안전하게 관리하기 위한 리스트
  final List<VoidCallback> _connectCallbacks = [];
  final List<VoidCallback> _disconnectCallbacks = [];
  final List<Function(Map<String, dynamic>)> _messageCallbacks = [];

  bool get isConnected => _isConnected;

  // 소켓 연결
  Future<void> connect(String serverUrl) async {
    try {
      // 기존 연결이 있으면 정리
      if (_socket != null) {
        _socket?.disconnect();
        _socket?.dispose();
        _socket = null;
      }

      _socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'forceNew': true, // 새로운 연결 강제
      });

      _socket?.on('connect', (_) {
        print('소켓 연결 성공');
        _isConnected = true;
        _receivedMessageIds.clear(); // 연결 시 메시지 ID 초기화
        _sendingMessages.clear(); // 전송 중 메시지 초기화

        // 안전한 콜백 실행
        _safeExecuteCallbacks(_connectCallbacks);
      });

      _socket?.on('disconnect', (_) {
        print('소켓 연결 해제');
        _isConnected = false;

        // 안전한 콜백 실행
        _safeExecuteCallbacks(_disconnectCallbacks);
      });

      _socket?.on('message', (data) {
        print('메시지 수신: $data');

        // 중복 메시지 체크
        if (data is Map<String, dynamic>) {
          final messageId = data['id']?.toString();
          if (messageId != null) {
            if (_receivedMessageIds.contains(messageId)) {
              print('중복 메시지 무시: $messageId');
              return;
            }
            _receivedMessageIds.add(messageId);

            // 메모리 관리: 100개 이상일 때 오래된 것 제거
            if (_receivedMessageIds.length > 100) {
              final oldIds = _receivedMessageIds.take(20).toList();
              _receivedMessageIds.removeAll(oldIds);
            }
          }
        }

        // 안전한 메시지 콜백 실행
        _safeExecuteMessageCallbacks(data);
      });

      _socket?.on('connect_error', (error) {
        print('소켓 연결 오류: $error');
        _isConnected = false;
      });

      // 방 참여 성공 이벤트
      _socket?.on('connected', (data) {
        print('방 참여 성공: $data');
      });

      // 사용자 입장 알림
      _socket?.on('user-joined', (data) {
        print('사용자 입장: $data');
      });

      // 사용자 퇴장 알림
      _socket?.on('user-left', (data) {
        print('사용자 퇴장: $data');
      });

      // 에러 이벤트
      _socket?.on('error', (data) {
        print('소켓 에러: $data');
      });

      _socket?.connect();
    } catch (e) {
      print('소켓 연결 중 예외 발생: $e');
      _isConnected = false;
    }
  }

  // 방 참여
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required String userNickname,
  }) async {
    if (_socket != null && _isConnected) {
      print('방 참여 요청: roomId=$roomId, userId=$userId, nickname=$userNickname');

      _socket?.emit('join-room', {
        'roomId': roomId,
        'userId': userId,
        'userNickname': userNickname,
      });
    } else {
      print('소켓이 연결되지 않아 방에 참여할 수 없습니다.');
      throw Exception('소켓 연결 없음');
    }
  }

  // 안전한 콜백 실행
  void _safeExecuteCallbacks(List<VoidCallback> callbacks) {
    for (final callback in List.from(callbacks)) {
      try {
        callback();
      } catch (e) {
        print('콜백 실행 중 오류: $e');
      }
    }
  }

  // 안전한 메시지 콜백 실행
  void _safeExecuteMessageCallbacks(dynamic data) {
    final messageData = data is Map<String, dynamic>
        ? data
        : {'text': data.toString(), 'isMe': false};

    for (final callback in List.from(_messageCallbacks)) {
      try {
        callback(messageData);
      } catch (e) {
        print('메시지 콜백 실행 중 오류: $e');
      }
    }
  }

  // 연결 상태 변화 리스너 등록
  void onConnect(VoidCallback callback) {
    _connectCallbacks.add(callback);
  }

  void onDisconnect(VoidCallback callback) {
    _disconnectCallbacks.add(callback);
  }

  void onMessage(Function(Map<String, dynamic>) callback) {
    _messageCallbacks.add(callback);
  }

  // 리스너 제거
  void removeConnectListener(VoidCallback callback) {
    _connectCallbacks.remove(callback);
  }

  void removeDisconnectListener(VoidCallback callback) {
    _disconnectCallbacks.remove(callback);
  }

  void removeMessageListener(Function(Map<String, dynamic>) callback) {
    _messageCallbacks.remove(callback);
  }

  // 모든 리스너 제거
  void removeAllListeners() {
    _connectCallbacks.clear();
    _disconnectCallbacks.clear();
    _messageCallbacks.clear();
  }

  // 메시지 전송 (중복 방지 로직 추가)
  Future<void> sendMessage({
    required String message,
    required String roomId,
    required String userId,
  }) async {
    if (!_isConnected || _socket == null) {
      print('소켓이 연결되지 않아 메시지를 전송할 수 없습니다.');
      throw Exception('소켓 연결 없음');
    }

    // 중복 전송 방지
    final messageKey = '$roomId:$userId:$message:${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
    if (_sendingMessages.containsKey(messageKey)) {
      print('이미 전송 중인 메시지: $messageKey');
      return;
    }

    _sendingMessages[messageKey] = true;

    try {
      _socket?.emit('message', {
        'text': message,
        'roomId': roomId,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 전송 완료 후 1초 뒤에 키 제거
      Timer(const Duration(seconds: 1), () {
        _sendingMessages.remove(messageKey);
      });

    } catch (e) {
      _sendingMessages.remove(messageKey);
      rethrow;
    }
  }

  // 소켓 연결 해제
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;

    // 모든 리스너 정리
    removeAllListeners();

    // 메시지 관련 데이터 정리
    _receivedMessageIds.clear();
    _sendingMessages.clear();
  }

  // 재연결 시도
  Future<void> reconnect(String serverUrl) async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect(serverUrl);
  }
}