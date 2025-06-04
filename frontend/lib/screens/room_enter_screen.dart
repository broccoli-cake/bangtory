import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import 'home_screen.dart';

class RoomEnterScreen extends StatefulWidget {
  const RoomEnterScreen({super.key});

  @override
  State<RoomEnterScreen> createState() => _RoomEnterScreenState();
}

class _RoomEnterScreenState extends State<RoomEnterScreen> {
  final TextEditingController _inviteCodeController = TextEditingController();

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final inviteCode = _inviteCodeController.text.trim();

    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드를 입력해주세요')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.joinRoom(inviteCode);

      // 방 참여 후 알림 개수 로드
      await appState.loadUnreadNotificationCount();

      // 방 참여 성공 시 홈 화면으로 이동
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              roomName: appState.currentRoom?.roomName ?? '방',
              userName: appState.currentUser?.name ?? '사용자',
            ),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 참여 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
<<<<<<< HEAD
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // 초대코드가 입력되어 있을 때만 이동하도록 간단 체크
                    if (_inviteCodeController.text.trim().isNotEmpty) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            roomName: '우리 방',   // 여기에 실제 방 이름 반영하기 (초대코드로 확인)
                            userName: 'user1',    // user1 아이콘 표시용 이름 (방장) 추후 실제 방장으로 변동 필요
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('초대 코드를 입력해주세요')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFA2E55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
=======
                  const SizedBox(height: 24),
                  const Text(
                    '방장에게 받은\n초대코드를 입력하세요.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '초대 코드',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inviteCodeController,
                    decoration: InputDecoration(
                      hintText: '예: ABC123',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
>>>>>>> ffbaa156a92efea73fa72adf1c42c26c2de1f2e7
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: appState.isLoading ? null : _joinRoom,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFA2E55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: appState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        '방 입장하기',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}