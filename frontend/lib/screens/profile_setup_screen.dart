import 'package:flutter/material.dart';
import 'go_room_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileSetupScreen extends StatefulWidget {
  final bool isResetMode;
  const ProfileSetupScreen({super.key, this.isResetMode = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();

}
class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _nicknameEdited = false; // 닉네임을 직접 입력했는지 여부
  @override
  void initState() {
    super.initState();
    _nicknameController.text = '울퉁불퉁 토마토'; // 기본 랜덤 닉네임
  }

  void _saveNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isResetMode
          ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '프로필 수정',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isResetMode
                  ? '닉네임을 수정하세요.'
                  : '안녕하세요!\n프로필을 만들어 주세요.',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[400],
                      child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nicknameController,
              onTap: () {
                if (!_nicknameEdited) {
                  _nicknameController.clear();
                  _nicknameEdited = true;
                }
              },
              decoration: InputDecoration(
                hintText: '닉네임을 입력하세요',
                filled: true,
                fillColor: const Color(0xFFFFE4E1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  String nickname = _nicknameController.text.trim();
                  if (nickname.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('닉네임을 입력해주세요!')),
                    );
                  } else {
                    _saveNickname(nickname);
                    if (widget.isResetMode) {
                      Navigator.pop(context); // 설정에서 왔다면 뒤로만 감
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GoRoomScreen()),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA2E55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> createRoom(String roomName, String address) async {
  final prefs = await SharedPreferences.getInstance();
  final jwt = prefs.getString('jwt') ?? '';

  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/rooms'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    },
    body: jsonEncode({
      'roomName': roomName,
      'address': address,
    }),
  );

  if (response.statusCode == 201) {
    print('방 생성 성공: ${response.body}');
  } else {
    print('방 생성 실패: ${response.body}');
  }
}