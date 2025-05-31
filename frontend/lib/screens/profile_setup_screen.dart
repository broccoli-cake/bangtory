import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import 'go_room_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _nicknameEdited = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  Future<void> _initializeUser() async {
    if (_isInitialized) return;

    final appState = Provider.of<AppState>(context, listen: false);

    // 기존 사용자가 있는지 확인
    await appState.loadUser();

    if (appState.currentUser == null) {
      // 새 사용자 생성
      try {
        await appState.createUser(nickname: '울퉁불퉁 토마토');
        setState(() {
          _nicknameController.text = appState.currentUser?.nickname ?? '울퉁불퉁 토마토';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 생성 실패: $e')),
        );
      }
    } else {
      setState(() {
        _nicknameController.text = appState.currentUser?.nickname ?? '울퉁불퉁 토마토';
      });
    }

    _isInitialized = true;
  }

  Future<void> _completeProfile() async {
    String nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요!')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.setProfile(nickname: nickname);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GoRoomScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 설정 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '안녕하세요!\n프로필을 만들어 주세요.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 50),
                // 프로필 이미지
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
                // 닉네임 입력창
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
                // 완료 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _completeProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFA2E55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}