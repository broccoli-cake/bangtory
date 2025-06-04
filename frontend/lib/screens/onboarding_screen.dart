import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import 'profile_setup_screen.dart';
import 'go_room_screen.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkUserStateAndNavigate();
  }

  Future<void> _checkUserStateAndNavigate() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);

      // 기존 사용자 데이터 로드 시도
      await appState.loadUser();

      // 6초 대기 (온보딩 화면 표시)
      await Future.delayed(const Duration(seconds: 6));

      if (!mounted) return;

      if (appState.currentUser == null) {
        // 사용자 데이터가 없으면 프로필 설정 화면으로
        _navigateToScreen(const ProfileSetupScreen());
      } else if (appState.currentRoom == null) {
        // 사용자는 있지만 방이 없으면 방 생성/참여 화면으로
        _navigateToScreen(const GoRoomScreen());
      } else {
        // 사용자와 방 모두 있으면 홈 화면으로
        // 알림 개수도 로드
        await appState.loadUnreadNotificationCount();

        _navigateToScreen(HomeScreen(
          roomName: appState.currentRoom!.roomName,
          userName: appState.currentUser!.name,
        ));
      }
    } catch (e) {
      print('사용자 상태 확인 중 오류: $e');
      // 오류 발생 시 프로필 설정 화면으로
      if (mounted) {
        _navigateToScreen(const ProfileSetupScreen());
      }
    }
  }


  void _navigateToScreen(Widget screen) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 그라데이션
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF17171), // 연한 빨강
                  Color(0xFFDFACAC), // 연한 핑크
                ],
              ),
            ),
          ),

          // 오른쪽 아래 토마토 느낌 원 + 별
          Positioned(
            bottom: 40.0,
            right: -screenWidth * 0.1,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: screenWidth * 0.8,
                  height: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  top: screenWidth * 0.06,
                  right: screenWidth * 0.08,
                  child: Icon(
                    Icons.star_rate_rounded,
                    size: screenWidth * 0.45,
                    color: Color(0xFFED8585),
                  ),
                ),
              ],
            ),
          ),

          // 텍스트
          Positioned(
            top: 200,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '함께하는 공간이',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '즐거워지는 시간,',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '방토리',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 로딩 인디케이터 (하단)
          if (_isChecking)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Column(
                children: const [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '사용자 정보를 확인하고 있습니다...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}