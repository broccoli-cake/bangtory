import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String _selectedProfileImage = '/images/profile1.png';

  // 제공되는 6개의 프로필 이미지
  final List<String> _profileImages = [
    '/images/profile1.png',
    '/images/profile2.png',
    '/images/profile3.png',
    '/images/profile4.png',
    '/images/profile5.png',
    '/images/profile6.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadUserProfile();

    setState(() {
      _nicknameController.text = appState.currentUserProfile?.nickname ?? '';
      _selectedProfileImage = appState.currentUserProfile?.profileImageUrl ?? '/images/profile1.png';
    });
  }

  Future<void> _updateProfile() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요.')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.updateUserProfile(
        nickname: nickname,
        profileImageUrl: _selectedProfileImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 수정되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필 수정 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '프로필 사진',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 현재 선택된 프로필 이미지
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            child: CircleAvatar(
              radius: 55,
              backgroundColor: _getProfileColor(_selectedProfileImage),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // 프로필 이미지 선택 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _profileImages.length,
          itemBuilder: (context, index) {
            final imageUrl = _profileImages[index];
            final isSelected = imageUrl == _selectedProfileImage;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProfileImage = imageUrl;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFA2E55) : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _getProfileColor(imageUrl),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 프로필 이미지별 색상 매핑
  Color _getProfileColor(String imageUrl) {
    switch (imageUrl) {
      case '/images/profile1.png':
        return Colors.red[400]!;
      case '/images/profile2.png':
        return Colors.blue[400]!;
      case '/images/profile3.png':
        return Colors.green[400]!;
      case '/images/profile4.png':
        return Colors.purple[400]!;
      case '/images/profile5.png':
        return Colors.orange[400]!;
      case '/images/profile6.png':
        return Colors.teal[400]!;
      default:
        return Colors.grey[400]!;
    }
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
          '프로필 관리',
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임 입력
                const Text(
                  '닉네임',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: '닉네임을 입력하세요',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFA2E55)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 프로필 이미지 선택
                _buildProfileImageSelector(),

                const SizedBox(height: 40),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: appState.isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFA2E55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: appState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      '저장하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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