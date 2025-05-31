
import 'package:flutter/material.dart';
import 'home_screen.dart';

class RoomMakingScreen extends StatefulWidget {
  const RoomMakingScreen({super.key});

  @override
  State<RoomMakingScreen> createState() => _RoomMakingScreenState();
}

class _RoomMakingScreenState extends State<RoomMakingScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _goToHomeScreen() {
    final roomName = _roomNameController.text.trim();

    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("방 이름을 입력해주세요.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          roomName: roomName,
          userName: '김민영', // profile_setup_screen.dart와 연동필요(단계별연동이 필요할수있음)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                '방 이름을 정해주세요.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                '방 이름',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  hintText: '',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                '주소',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: '예: 판교대로 235, 분당 주소, 성남동 681',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _goToHomeScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFA2E55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '방 만들기',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}