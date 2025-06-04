import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import 'go_room_screen.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
<<<<<<< HEAD
  final bool isResetMode;
  const ProfileSetupScreen({super.key, this.isResetMode = false});
=======
  const ProfileSetupScreen({super.key});
>>>>>>> ffbaa156a92efea73fa72adf1c42c26c2de1f2e7

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
<<<<<<< HEAD
  final TextEditingController _nicknameController = TextEditingController();
  bool _nicknameEdited = false; // 닉네임을 직접 입력했는지 여부

  //이미지 색상 위한 변수
  Color _profileColor = Colors.pinkAccent; // 기본값
  final List<Color> _colorOptions = [Colors.pinkAccent, Colors.orange, Colors.green, Colors.blue, Colors.purple];
=======
  final TextEditingController _nameController = TextEditingController();
  bool _nameEdited = false;
  bool _isInitialized = false;
>>>>>>> ffbaa156a92efea73fa72adf1c42c26c2de1f2e7

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    if (widget.isResetMode) {
      _loadProfileData(); // [추가] 프로필 수정 모드일 때 기존 데이터 불러오기
    } else {
      _nicknameController.text = '울퉁불퉁 토마토'; // 기본 랜덤 닉네임
    }
  }

  // [추가] 기존 프로필 불러오기 함수
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nicknameController.text = prefs.getString('nickname') ?? '울퉁불퉁 토마토';
      _profileColor = Color(prefs.getInt('profileColor') ?? Colors.pinkAccent.value);
    });
  }

  void _saveProfileSettings(String nickname, Color color) async {    //_saveNickname에서 이미지까지 합친 걸로 바꿈
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    await prefs.setInt('profileColor', color.value);
  }

  void _showColorPicker() {    //프로필 색상 선택
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 색상을 선택하세요'),
        content: Wrap(
          spacing: 10,
          children: _colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _profileColor = color;
                });
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: color,
                radius: 20,
                child: _profileColor == color
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
=======
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
>>>>>>> ffbaa156a92efea73fa72adf1c42c26c2de1f2e7
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
<<<<<<< HEAD
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
            Center(     //프로필 이미지 부분 수정
              child: Stack(
                children: [
                  CircleAvatar(
=======
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
>>>>>>> ffbaa156a92efea73fa72adf1c42c26c2de1f2e7
                    radius: 80,
                    backgroundColor: _profileColor,
                    child: const Icon(
                      Icons.face,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
<<<<<<< HEAD
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showColorPicker,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[400],
                        child: const Icon(Icons.color_lens_outlined, size: 20, color: Colors.white),
                      ),
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
=======
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
>>>>>>> ffbaa156a92efea73fa72adf1c42c26c2de1f2e7
                ),
              ],
            ),
<<<<<<< HEAD
            const Spacer(),

            // [추가] 방 나가기, 탈퇴하기 버튼 (isResetMode일 때만)
            if (widget.isResetMode)
              Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: 방 나가기 처리
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('정말 방을 나가시겠어요?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                              TextButton(
                                onPressed: () {
                                  // TODO: 실제 방 나가기 로직
                                  Navigator.pop(context);
                                },
                                child: const Text('나가기', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('방 나가기', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: 탈퇴 처리
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('정말 탈퇴하시겠어요?'),
                            content: const Text('탈퇴하면 모든 정보가 삭제됩니다.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                              TextButton(
                                onPressed: () {
                                  // TODO: 실제 탈퇴 처리
                                  Navigator.pop(context);
                                },
                                child: const Text('탈퇴하기', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('탈퇴하기', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
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
                    _saveProfileSettings(nickname, _profileColor);   //완료 버튼 내 저장 로직 변경
                    if (widget.isResetMode) {
                      Navigator.pop(context, true); // 수정 모드일 경우, true 반환해서 SettingsScreen에 알림
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const GoRoomScreen()),
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
=======
          );
        },
      ),
    );
  }
}
>>>>>>> ffbaa156a92efea73fa72adf1c42c26c2de1f2e7
