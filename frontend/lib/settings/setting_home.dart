import 'package:flutter/material.dart';
import 'package:frontend/settings/notice/notice_screen.dart';

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
            onPressed: () {
              Navigator.pop(context);
              // TODO: 로그아웃 처리 로직 추가
            },
            child: const Text('확인'),
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildSettingsItem(
            label: '프로필 관리',
            onTap: () {
              // TODO: 프로필 화면으로 이동
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
            onTap: () {
              // TODO: 방 관리 화면으로 이동
            },
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
            trailing: const SizedBox.shrink(), // > 아이콘 제거
          ),
        ],
      ),
    );
  }
}
