import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import './onboarding_screen.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoomInfo();
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadRoomInfo() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentRoom != null) {
      _roomNameController.text = appState.currentRoom!.roomName;
      _addressController.text = appState.currentRoom!.address ?? '';
    }
  }

  // 프로필 이미지별 색상 매핑
  Color _getProfileColor(String? profileImageUrl) {
    switch (profileImageUrl) {
      case '/images/profile1.png':
        return Colors.red[400]!;
      case '/images/profile2.png':
        return Colors.blue[400]!;
      case '/images/profile3.png':
        return Colors.green[400]!;
      case '/images/profile4.png':
        return Colors.purple[400]!;
      case '/images/profile5.png':
        return Colors.orange[400]!;
      case '/images/profile6.png':
        return Colors.teal[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  Future<void> _updateRoomInfo() async {
    final roomName = _roomNameController.text.trim();
    final address = _addressController.text.trim();

    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 이름을 입력해주세요.')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.updateRoom(
        roomName: roomName,
        address: address.isNotEmpty ? address : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방 정보가 수정되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('방 정보 수정 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTransferOwnershipDialog(Map<String, dynamic> member) {
    final memberNickname = member['nickname'] ?? '알 수 없음';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('방장 위임'),
        content: Text('$memberNickname님에게 방장을 위임하시겠습니까?\n\n위임 후에는 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA2E55),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _transferOwnership(member['userId']);
            },
            child: const Text('위임', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _transferOwnership(String newOwnerId) async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.transferOwnership(newOwnerId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방장이 위임되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );

      // 방장이 바뀌었으므로 화면을 닫고 설정 화면으로 돌아감
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('방장 위임 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showKickMemberDialog(Map<String, dynamic> member) {
    final memberNickname = member['nickname'] ?? '알 수 없음';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멤버 내보내기'),
        content: Text('$memberNickname님을 방에서 내보내시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _kickMember(member['userId']);
            },
            child: const Text('내보내기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _kickMember(String userId) async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.kickMember(userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('멤버가 내보내졌습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('멤버 내보내기 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMemberItem(Map<String, dynamic> member, bool isOwner, String currentUserId) {
    final nickname = member['nickname'] ?? '알 수 없음';
    final isCurrentUser = member['userId'] == currentUserId;
    final isMemberOwner = member['isOwner'] == true;
    final profileImageUrl = member['profileImageUrl'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: isOwner && !isCurrentUser && !isMemberOwner
              ? () => _showTransferOwnershipDialog(member)
              : null,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _getProfileColor(profileImageUrl),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (isMemberOwner)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              if (isOwner && !isCurrentUser && !isMemberOwner)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFA2E55),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Row(
          children: [
            Text(nickname),
            if (isMemberOwner)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '방장',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            if (isCurrentUser)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA2E55),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '나',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        subtitle: Text(
          isOwner && !isCurrentUser && !isMemberOwner
              ? '프로필을 터치하여 방장 위임'
              : '참여 날짜: ${DateTime.tryParse(member['joinedAt'] ?? '')?.toLocal().toString().split(' ')[0] ?? '알 수 없음'}',
          style: TextStyle(
            fontSize: 12,
            color: isOwner && !isCurrentUser && !isMemberOwner
                ? const Color(0xFFFA2E55)
                : Colors.grey[600],
          ),
        ),
        trailing: isOwner && !isCurrentUser && !isMemberOwner
            ? IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () => _showKickMemberDialog(member),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '방 관리',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appState.currentRoom == null) {
            return const Center(
              child: Text('방 정보를 불러올 수 없습니다.'),
            );
          }

          final isOwner = appState.currentRoom!.isOwner;
          final currentUserId = appState.currentUser?.id ?? '';
          final totalMembers = appState.roomMembers.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 방 정보 섹션
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '방 정보',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (!isOwner)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '방장만 수정 가능',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 방 이름
                      const Text(
                        '방 이름',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _roomNameController,
                        enabled: isOwner,
                        decoration: InputDecoration(
                          hintText: '방 이름을 입력하세요',
                          filled: true,
                          fillColor: isOwner ? Colors.white : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFFA2E55)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 주소
                      const Text(
                        '주소',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _addressController,
                        enabled: isOwner,
                        decoration: InputDecoration(
                          hintText: '주소를 입력하세요 (선택사항)',
                          filled: true,
                          fillColor: isOwner ? Colors.white : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFFA2E55)),
                          ),
                        ),
                      ),

                      if (isOwner) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFA2E55),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _updateRoomInfo,
                            child: const Text(
                              '수정하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 방 멤버 섹션
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '방 멤버',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFA2E55),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${appState.roomMembers.length}명',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (isOwner) ...[
                        const SizedBox(height: 8),
                        Text(
                          '💡 프로필을 터치하여 방장을 위임할 수 있습니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // 멤버 목록
                      ...appState.roomMembers.map((member) {
                        return _buildMemberItem(member, isOwner, currentUserId);
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 초대 코드 생성 버튼
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '멤버 초대',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '새로운 멤버를 초대하려면 초대 코드를 생성하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              final inviteCode = await appState.generateInviteCode();
                              _showInviteCodeDialog(inviteCode);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('초대 코드 생성 실패: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text(
                            '초대 코드 생성',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 방 나가기 섹션 (수정됨)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '방 나가기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOwner
                            ? totalMembers > 1
                            ? '⚠️ 방장은 다른 멤버에게 방장을 위임한 후 나갈 수 있습니다.'
                            : '⚠️ 방장이 나가면 방이 삭제됩니다.'
                            : '방을 나가면 다시 초대 코드로만 들어올 수 있습니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: (isOwner && totalMembers > 1) ? null : () => _showLeaveRoomDialog(),
                          child: Text(
                            isOwner && totalMembers > 1
                                ? '방장 위임 후 나가기 가능'
                                : isOwner
                                ? '방 삭제하고 나가기'
                                : '방 나가기',
                            style: TextStyle(
                              color: (isOwner && totalMembers > 1) ? Colors.grey[400] : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInviteCodeDialog(String inviteCode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('초대 코드'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('다음 코드를 새로운 멤버에게 공유하세요:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                inviteCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '⏰ 코드는 3시간 후 만료됩니다',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA2E55),
            ),
            onPressed: () {
              // 클립보드에 복사
              Clipboard.setData(ClipboardData(text: inviteCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('초대 코드가 복사되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('복사', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeaveRoomDialog() {
    final appState = Provider.of<AppState>(context, listen: false);
    final isOwner = appState.currentRoom?.isOwner ?? false;
    final totalMembers = appState.roomMembers.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isOwner ? '방 삭제' : '방 나가기',
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(
          isOwner
              ? '정말로 방을 삭제하시겠습니까?\n\n방장이 나가면 방이 완전히 삭제되며, 모든 데이터가 사라집니다.'
              : '정말로 방을 나가시겠습니까?\n\n나간 후에는 초대 코드로만 다시 들어올 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _leaveRoom();
            },
            child: Text(
              isOwner ? '삭제' : '나가기',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveRoom() async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.leaveRoom();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방을 나왔습니다.'),
          backgroundColor: Colors.green,
        ),
      );

      // 방을 나간 후 온보딩 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('방 나가기 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}