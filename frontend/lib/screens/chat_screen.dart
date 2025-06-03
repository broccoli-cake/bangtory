import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../utils/app_state.dart';

class ChatRoomScreenWithSocket extends StatefulWidget {
  const ChatRoomScreenWithSocket({super.key});

  @override
  State<ChatRoomScreenWithSocket> createState() => _ChatRoomScreenWithSocketState();
}

class _ChatRoomScreenWithSocketState extends State<ChatRoomScreenWithSocket> {
  final TextEditingController _controller = TextEditingController();
  late ChatService _chatService;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isLoadingMessages = false;

  final List<Map<String, dynamic>> _messages = [];
  final Set<String> _messageIds = <String>{}; // 중복 메시지 방지

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _cleanupChat();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      _chatService = ChatService();

      // 안전한 리스너 등록
      _chatService.onConnect(() {
        if (mounted) {
          setState(() {
            _isConnected = true;
            _isConnecting = false;
          });

          // 연결 성공 후 자동으로 방 참여
          _joinCurrentRoom();
        }
      });

      _chatService.onDisconnect(() {
        if (mounted) {
          setState(() {
            _isConnected = false;
            _isConnecting = false;
          });
        }
      });

      _chatService.onMessage((message) {
        if (mounted) {
          _addMessageSafely(message);
        }
      });

      // 서버 연결
      await _chatService.connect('http://10.0.2.2:3000'); // Android 에뮬레이터용

    } catch (e) {
      print('채팅 초기화 오류: $e');
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isConnecting = false;
        });
        _showErrorSnackBar('채팅 연결에 실패했습니다. 다시 시도해주세요.');
      }
    }
  }

  // 메시지 안전하게 추가 (중복 방지)
  void _addMessageSafely(Map<String, dynamic> message) {
    final messageId = message['id']?.toString();
    final messageText = message['text']?.toString() ?? '';
    final userId = message['userId']?.toString();
    final timestamp = message['timestamp']?.toString();

    // 고유 키 생성 (id가 없는 경우 다른 필드들로 생성)
    final uniqueKey = messageId ?? '$userId:$messageText:$timestamp';

    if (_messageIds.contains(uniqueKey)) {
      print('중복 메시지 무시: $uniqueKey');
      return;
    }

    _messageIds.add(uniqueKey);

    // 메모리 관리
    if (_messageIds.length > 200) {
      final oldIds = _messageIds.take(50).toList();
      _messageIds.removeAll(oldIds);
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final currentUserId = appState.currentUser?.id;

    setState(() {
      _messages.add({
        'id': uniqueKey,
        'text': messageText,
        'isMe': userId == currentUserId,
        'timestamp': DateTime.tryParse(timestamp ?? '') ?? DateTime.now(),
        'userId': userId,
        'userNickname': message['userNickname'],
        'status': 'received',
      });
    });
  }

  // 현재 방에 참여하는 로직
  Future<void> _joinCurrentRoom() async {
    final appState = Provider.of<AppState>(context, listen: false);

    if (appState.currentRoom != null && appState.currentUser != null) {
      try {
        // 사용자 프로필 정보 가져오기 (닉네임 포함)
        String userNickname = appState.currentUser!.name; // 기본값으로 name 사용

        // 프로필 정보가 있으면 닉네임 사용
        if (appState.currentUserProfile?.nickname != null) {
          userNickname = appState.currentUserProfile!.nickname;
        }

        print('방 참여 시도: roomId=${appState.currentRoom!.roomId}, userId=${appState.currentUser!.id}, nickname=$userNickname');

        await _chatService.joinRoom(
          roomId: appState.currentRoom!.roomId,
          userId: appState.currentUser!.id,
          userNickname: userNickname,
        );

        print('방 참여 성공');

        // 방 참여 후 기존 메시지 기록 로드
        await _loadMessageHistory();

      } catch (e) {
        print('방 참여 오류: $e');
        _showErrorSnackBar('방 참여에 실패했습니다.');
      }
    } else {
      print('방 정보 또는 사용자 정보가 없습니다.');
      _showErrorSnackBar('방 정보를 불러올 수 없습니다.');
    }
  }

  // 메시지 기록 로드
  Future<void> _loadMessageHistory() async {
    if (_isLoadingMessages) return;

    setState(() {
      _isLoadingMessages = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.currentRoom == null) return;

      final messages = await appState.apiService.getChatMessages(
        roomId: appState.currentRoom!.roomId,
        page: 1,
        limit: 50,
      );

      if (mounted) {
        setState(() {
          _messages.clear();
          _messageIds.clear();
        });

        // 기존 메시지들을 안전하게 추가
        for (final message in messages) {
          _addMessageSafely({
            'id': message['id'],
            'text': message['message'],
            'userId': message['userId'],
            'userNickname': message['username'],
            'timestamp': message['timestamp'],
          });
        }
      }
    } catch (e) {
      print('메시지 기록 로드 오류: $e');
      // 오류가 발생해도 채팅은 계속 사용할 수 있도록 함
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
      }
    }
  }

  void _cleanupChat() {
    try {
      _chatService.removeAllListeners();
      _chatService.disconnect();
    } catch (e) {
      print('채팅 정리 중 오류: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '다시 시도',
            textColor: Colors.white,
            onPressed: _initializeChat,
          ),
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected) return;

    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentRoom == null || appState.currentUser == null) {
      _showErrorSnackBar('방 정보를 찾을 수 없습니다.');
      return;
    }

    // 즉시 UI 업데이트 (낙관적 업데이트)
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newMessage = {
      'id': tempId,
      'text': text,
      'isMe': true,
      'timestamp': DateTime.now(),
      'status': 'sending', // 전송 중 상태
      'userId': appState.currentUser!.id,
    };

    // 중복 방지를 위해 메시지 ID 추가
    if (!_messageIds.contains(tempId)) {
      _messageIds.add(tempId);
      setState(() {
        _messages.add(newMessage);
        _controller.clear();
      });
    }

    try {
      await _chatService.sendMessage(
        message: text,
        roomId: appState.currentRoom!.roomId,
        userId: appState.currentUser!.id,
      );

      // 전송 성공 시 상태 업데이트
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((msg) => msg['id'] == tempId);
          if (index != -1) {
            _messages[index]['status'] = 'sent';
          }
        });
      }
    } catch (e) {
      print('메시지 전송 오류: $e');

      // 전송 실패 시 상태 업데이트
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((msg) => msg['id'] == tempId);
          if (index != -1) {
            _messages[index]['status'] = 'failed';
          }
        });

        _showErrorSnackBar('메시지 전송에 실패했습니다.');
      }
    }
  }

  Widget _buildMessageStatus(Map<String, dynamic> message) {
    if (!message['isMe'] || !message.containsKey('status')) {
      return const SizedBox.shrink();
    }

    final status = message['status'];
    switch (status) {
      case 'sending':
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case 'sent':
      case 'received':
        return const Icon(
          Icons.check,
          size: 12,
          color: Colors.white70,
        );
      case 'failed':
        return const Icon(
          Icons.error_outline,
          size: 12,
          color: Colors.red,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _isConnected
                  ? Colors.green
                  : _isConnecting
                  ? Colors.orange
                  : Colors.grey,
              child: _isConnecting
                  ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(
                _isConnected ? Icons.chat : Icons.chat_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '채팅방',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                Text(
                  _isConnecting
                      ? '연결 중...'
                      : _isConnected
                      ? '연결됨'
                      : '연결 실패',
                  style: TextStyle(
                    color: _isConnected
                        ? Colors.green
                        : _isConnecting
                        ? Colors.orange
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (!_isConnected && !_isConnecting)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializeChat,
              tooltip: '다시 연결',
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _loadMessageHistory,
            tooltip: '메시지 기록 새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 연결 상태 알림 바
          if (_isConnecting || !_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: _isConnecting
                  ? Colors.orange.shade100
                  : Colors.red.shade100,
              child: Row(
                children: [
                  if (_isConnecting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    )
                  else
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _isConnecting
                        ? '채팅 서버에 연결 중입니다...'
                        : '채팅 서버 연결이 끊어졌습니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isConnecting ? Colors.orange : Colors.red,
                    ),
                  ),
                  if (!_isConnecting) ...[
                    const Spacer(),
                    TextButton(
                      onPressed: _initializeChat,
                      child: const Text(
                        '다시 연결',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // 메시지 로딩 인디케이터
          if (_isLoadingMessages)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '메시지 기록을 불러오는 중...',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final appState = Provider.of<AppState>(context, listen: false);

                // 내가 보낸 메시지인지 확인
                final isMe = message['userId'] == appState.currentUser?.id ||
                    message['isMe'] == true;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? (message['status'] == 'failed'
                          ? Colors.red.shade300
                          : const Color(0xFFFA2E55))
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 다른 사용자 메시지인 경우 닉네임 표시
                        if (!isMe && message['userNickname'] != null) ...[
                          Text(
                            message['userNickname'],
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],

                        Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),

                        // 내 메시지인 경우 상태와 시간 표시
                        if (isMe) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (message.containsKey('timestamp'))
                                Text(
                                  TimeOfDay.fromDateTime(message['timestamp']).format(context),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              _buildMessageStatus(message),
                            ],
                          ),
                        ] else if (message.containsKey('timestamp')) ...[
                          // 다른 사용자 메시지의 시간 표시
                          const SizedBox(height: 4),
                          Text(
                            TimeOfDay.fromDateTime(message['timestamp']).format(context),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: _isConnected,
                      decoration: InputDecoration(
                        hintText: _isConnected
                            ? '메시지를 입력하세요'
                            : '연결 대기 중...',
                        hintStyle: const TextStyle(fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                          const BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                          const BorderSide(color: Color(0xFFFA2E55), width: 1),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                          const BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isConnected
                          ? const Color(0xFFFA2E55)
                          : Colors.grey,
                    ),
                    onPressed: _isConnected ? _sendMessage : null,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}