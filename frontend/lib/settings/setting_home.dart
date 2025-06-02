import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/settings/notice/notice_screen.dart';
import 'package:frontend/screens/onboarding_screen.dart';
import '../screens/profile_management_screen.dart';
import '../screens/room_management_screen.dart';
import '../utils/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isPushEnabled = true;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃을 하시겠습니까?'),
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
              Navigator.pop(context); // 다이얼로그 닫기

              // 로그아웃 처리
              final appState = Provider.of<AppState>(context, listen: false);
              try {
                await appState.logout();

                // 온보딩 화면으로 즉시 이동
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                        (route) => false, // 모든 이전 화면 제거
                  );
                }
              } catch (e) {
                // mounted 체크 추가
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그아웃 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('확인', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 16, color: textColor ?? Colors.black)),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          ],
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
          '설정',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final hasRoom = appState.currentRoom != null;

          return Column(
            children: [
              const SizedBox(height: 10),
              _buildSettingsItem(
                label: '프로필 관리',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileManagementScreen()),
                  );
                },
              ),
              _buildSettingsItem(
                label: '푸시알림',
                trailing: Switch(
                  value: isPushEnabled,
                  activeColor: const Color(0xFFFA2E55),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                  onChanged: (value) {
                    setState(() {
                      isPushEnabled = value;
                    });
                  },
                ),
              ),
              _buildSettingsItem(
                label: '방 관리',
                onTap: hasRoom ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomManagementScreen()),
                  );
                } : null,
                textColor: hasRoom ? Colors.black : Colors.grey,
                trailing: hasRoom
                    ? const Icon(Icons.chevron_right, color: Colors.grey)
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '방에 참여해주세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.lock, color: Colors.grey, size: 16),
                  ],
                ),
              ),
              _buildSettingsItem(
                label: '공지사항',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NoticeScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSettingsItem(
                label: '로그아웃',
                textColor: const Color(0xFFFA2E55),
                onTap: _showLogoutDialog,
                trailing: const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}