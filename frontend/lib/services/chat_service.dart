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

  // 콜백 함수들을 안전하게 관리하기 위한 리스트
  final List<VoidCallback> _connectCallbacks = [];
  final List<VoidCallback> _disconnectCallbacks = [];
  final List<Function(Map<String, dynamic>)> _messageCallbacks = [];

  bool get isConnected => _isConnected;

  // 소켓 연결
  Future<void> connect(String serverUrl) async {
    try {
      _socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket?.on('connect', (_) {
        print('소켓 연결 성공');
        _isConnected = true;

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

  // 메시지 전송
  Future<void> sendMessage({
    required String message,
    required String roomId,
    required String userId,
  }) async {
    if (_socket != null && _isConnected) {
      _socket?.emit('message', {
        'text': message,
        'roomId': roomId,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      print('소켓이 연결되지 않아 메시지를 전송할 수 없습니다.');
      throw Exception('소켓 연결 없음');
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
  }

  // 재연결 시도
  Future<void> reconnect(String serverUrl) async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect(serverUrl);
  }
}