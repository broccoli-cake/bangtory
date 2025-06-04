//방 이름 수정 가능하게 변경 필요

import 'package:flutter/material.dart';
import 'package:frontend/screens/onboarding_screen.dart'; // 온보딩 화면 import

class RoomManagementScreen extends StatefulWidget {
  final String roomName;

  const RoomManagementScreen({super.key, required this.roomName});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  late String _currentRoomName;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentRoomName = widget.roomName;
    _nameController.text = widget.roomName;
  }

  void _showEditRoomNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("방 이름 수정"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: "새 방 이름 입력"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentRoomName = _nameController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("방 삭제"),
        content: const Text("이 방을 정말 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);  //다이얼로그 닫기
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    (route) => false, // 모든 이전 화면 제거
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("삭제"),
          ),
        ],
      ),
    );
  }


  Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '방 관리',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('방 이름', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentRoomName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black54),
                    onPressed: _showEditRoomNameDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildMenuItem("멤버 관리", onTap: () {
              // TODO: 멤버 관리 화면 연결
            }),
            _buildMenuItem("멤버 초대", onTap: () {
              // TODO: 멤버 초대 화면 연결
            }),
            const SizedBox(height: 20),
            ListTile(
              title: const Text(
                "방 삭제",
                style: TextStyle(color: Colors.red),
              ),
              onTap: _showDeleteConfirmationDialog,
            ),
          ],
        ),
      ),
    );
  }
}
