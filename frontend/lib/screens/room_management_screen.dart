import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import './go_room_screen.dart';

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
        return const Color(0xFF4CAF50);
      case '/images/profile2.png':
        return const Color(0xFF8BC34A);
      case '/images/profile3.png':
        return const Color(0xFFFFEB3B);
      case '/images/profile4.png':
        return const Color(0xFFFF9800);
      case '/images/profile5.png':
        return const Color(0xFFFF5722);
      case '/images/profile6.png':
        return const Color(0xFFFA2E55);
      default:
        return const Color(0xFFFA2E55);
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

      // 성공 후 알림 개수 업데이트
      await appState.loadUnreadNotificationCount();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방 정보가 수정되었습니다.'),
          backgroundColor: Colors.lightGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('방 정보 수정 실패: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showTransferOwnershipDialog(Map<String, dynamic> member) {
    final memberNickname = member['nickname'] ?? '알 수 없음';

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('방장 위임'),
            content: Text(
                '$memberNickname님에게 방장을 위임하시겠습니까?\n\n⚠️ 위임 후에는 되돌릴 수 없습니다.\n위임 후 일반 멤버가 됩니다.'),
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

      // 성공 후 알림 개수 업데이트
      await appState.loadUnreadNotificationCount();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방장이 위임되었습니다.'),
          backgroundColor: Colors.lightGreen,
        ),
      );

      // 방장이 바뀌었으므로 화면을 닫고 설정 화면으로 돌아감
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('방장 위임 실패: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showKickMemberDialog(Map<String, dynamic> member) {
    final memberNickname = member['nickname'] ?? '알 수 없음';

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('멤버 내보내기'),
            content: Text('$memberNickname님을 방에서 내보내시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _kickMember(member['userId']);
                },
                child: const Text(
                    '내보내기', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  Future<void> _kickMember(String userId) async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.kickMember(userId);

      // 성공 후 알림 개수 업데이트
      await appState.loadUnreadNotificationCount();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('멤버가 내보내졌습니다.'),
          backgroundColor: Colors.lightGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('멤버 내보내기 실패: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildMemberItem(Map<String, dynamic> member, bool isOwner,
      String currentUserId) {
    final nickname = member['nickname'] ?? '알 수 없음';
    final isCurrentUser = member['userId'] == currentUserId;
    final isMemberOwner = member['isOwner'] == true;
    final profileImageUrl = member['profileImageUrl'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isMemberOwner ? 2 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isMemberOwner
              ? Border.all(color: Colors.amber, width: 2)
              : null,
        ),
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
                    Icons.face,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                // 방장 표시
                if (isMemberOwner)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  nickname,
                  overflow: TextOverflow.ellipsis, // 넘치면 "..." 처리
                  style: TextStyle(
                    fontWeight: isMemberOwner ? FontWeight.bold : FontWeight
                        .normal,
                  ),
                ),
              ),
              if (isMemberOwner)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '방장',
                    style: TextStyle(color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              if (isCurrentUser)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFA2E55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '나',
                    style: TextStyle(color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '참여일: ${DateTime
                .tryParse(member['joinedAt'] ?? '')
                ?.toLocal()
                .toString()
                .split(' ')[0] ?? '알 수 없음'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
          ),
          trailing: isOwner && !isCurrentUser && !isMemberOwner
              ? PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'transfer') {
                _showTransferOwnershipDialog(member);
              } else if (value == 'kick') {
                _showKickMemberDialog(member);
              }
            },
            itemBuilder: (context) =>
            [
              const PopupMenuItem(
                value: 'transfer',
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 8),
                    Text('방장 위임'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'kick',
                child: Row(
                  children: [
                    Icon(
                        Icons.face_retouching_off, color: Colors.redAccent, size: 16),
                    SizedBox(width: 8),
                    Text('내보내기'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, color: Colors.grey),
          )
              : null,
        ),
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

          // 멤버 정렬: 본인이 맨 앞, 그 다음은 방 입장 순서대로
          final sortedMembers = List<Map<String, dynamic>>.from(appState.roomMembers);

          sortedMembers.sort((a, b) {
            final aUserId = a['userId']?.toString();
            final bUserId = b['userId']?.toString();

            // 본인이면 맨 앞으로
            if (aUserId == currentUserId && bUserId != currentUserId) return -1;
            if (bUserId == currentUserId && aUserId != currentUserId) return 1;

            // 둘 다 본인이 아니면 입장한 순서대로
            DateTime? aTime;
            DateTime? bTime;

            // joinedAt 시도
            if (a['joinedAt'] != null) {
              aTime = DateTime.tryParse(a['joinedAt'].toString());
            }
            if (b['joinedAt'] != null) {
              bTime = DateTime.tryParse(b['joinedAt'].toString());
            }

            // joinedAt이 없으면 createdAt 시도
            if (aTime == null && a['createdAt'] != null) {
              aTime = DateTime.tryParse(a['createdAt'].toString());
            }
            if (bTime == null && b['createdAt'] != null) {
              bTime = DateTime.tryParse(b['createdAt'].toString());
            }

            // 둘 다 있으면 비교 (먼저 입장한 순서)
            if (aTime != null && bTime != null) {
              return aTime.compareTo(bTime);
            }

            // 시간 정보가 없으면 _id로 비교
            final aId = a['_id']?.toString() ?? '';
            final bId = b['_id']?.toString() ?? '';
            return aId.compareTo(bId);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 방 권한 상태 표시
                if (isOwner)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '방장 권한으로 방 정보 수정, 멤버 관리, 방장 위임이 가능합니다.',
                            style: TextStyle(
                              color: Colors.amber.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[200]!),
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[200]!),
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
                              '${sortedMembers.length}명',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 정렬된 멤버 목록
                      ...sortedMembers.map((member) {
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
                            backgroundColor: Colors.lightGreen,
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
                                  backgroundColor: Colors.redAccent,
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

                // 방 나가기 섹션
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
                          color: Colors.redAccent,
                        ),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOwner ? Colors.grey[400] : Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isOwner ? null : () => _showLeaveRoomDialog(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isOwner ? Icons.block : Icons.exit_to_app,
                                color: isOwner ? Colors.grey[600] : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isOwner ? '방장 위임 후 나가기 가능' : '방 나가기',
                                style: TextStyle(
                                  color: isOwner ? Colors.grey[600] : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 방 삭제하기 섹션 (방장만 표시)
                if (isOwner)
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
                          '방 삭제하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _showDeleteRoomDialog(),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '방 삭제하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
      builder: (_) =>
          AlertDialog(
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
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('초대 코드가 복사되었습니다'),
                      backgroundColor: Colors.lightGreen,
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
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text(
              '방 나가기',
              style: TextStyle(color: Colors.redAccent),
            ),
            content: const Text(
              '정말로 방을 나가시겠습니까?\n\n나간 후에는 기존 데이터가 삭제됩니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _leaveRoom();
                },
                child: const Text(
                  '나가기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600, size: 24),
            const SizedBox(width: 8),
            const Text(
              '방 삭제 확인',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '정말로 이 방을 삭제하시겠습니까?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '삭제 시 일어나는 일:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 모든 멤버가 자동으로 방에서 나가게 됩니다\n'
                        '• 모든 집안일 일정이 삭제됩니다\n'
                        '• 모든 예약 데이터가 삭제됩니다\n'
                        '• 채팅 기록이 삭제됩니다\n'
                        '• 이 작업은 되돌릴 수 없습니다',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteRoom();
            },
            child: const Text(
              '삭제',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _deleteRoom() async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('방을 삭제하는 중...'),
            ],
          ),
        ),
      );

      await appState.deleteRoom();

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방이 삭제되었습니다.'),
          backgroundColor: Colors.lightGreen,
        ),
      );

      // 방이 삭제된 후 방 생성/참여 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GoRoomScreen()),
            (route) => false,
      );
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('방 삭제 실패: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _leaveRoom() async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.leaveRoom();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방을 나왔습니다.'),
          backgroundColor: Colors.lightGreen,
        ),
      );

      // 방을 나간 후 방 생성/참여 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GoRoomScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('방 나가기 실패: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
