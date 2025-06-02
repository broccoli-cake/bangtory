import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import 'go_room_screen.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _nameEdited = false;
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

    // 기존 사용자 데이터 로드 시도
    await appState.loadUser();

    if (appState.currentUser == null) {
      // 기본 이름 설정
      setState(() {
        _nameController.text = '사용자';
      });
    } else {
      setState(() {
        _nameController.text = appState.currentUser?.name ?? '사용자';
      });

      // 이미 사용자가 있고 방도 있다면 홈으로 이동
      if (appState.currentRoom != null) {
        _navigateToHome(appState);
        return;
      }

      // 사용자는 있지만 방이 없다면 방 생성/참여 화면으로
      if (appState.currentRoom == null) {
        _navigateToGoRoom();
        return;
      }
    }

    _isInitialized = true;
  }

  void _navigateToGoRoom() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GoRoomScreen()),
      );
    }
  }

  void _navigateToHome(AppState appState) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            roomName: appState.currentRoom!.roomName,
            userName: appState.currentUser!.name,
          ),
        ),
      );
    }
  }

  Future<void> _completeSetup() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요!')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      // 사용자 생성 (이름만)
      await appState.createUser(name: name);

      // 방 생성/참여 화면으로 이동
      _navigateToGoRoom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 생성 실패: $e')),
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
                  '안녕하세요!\n이름을 입력해주세요.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 50),
                // 기본 프로필 이미지 (수정 불가)
                Center(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // 이름 입력창
                TextField(
                  controller: _nameController,
                  onTap: () {
                    if (!_nameEdited) {
                      _nameController.clear();
                      _nameEdited = true;
                    }
                  },
                  decoration: InputDecoration(
                    hintText: '이름을 입력하세요',
                    filled: true,
                    fillColor: const Color(0xFFFFE4E1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '* 닉네임과 프로필 사진은 방 입장 후 자동 생성됩니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                // 완료 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _completeSetup,
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