import 'package:flutter/material.dart';
import 'profile_setup_screen.dart'; // 추가: 프로필 설정 화면 import

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // BANGTORY 텍스트
              Text(
                'BANGTORY',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '룸메이트 필수앱',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),

              const SizedBox(height: 40),

              // 동그라미 안에 초록 별
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.star,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
              ),

              const Spacer(),

              // 네이버 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03C75A), // 네이버 초록
                  ),
                  child: const Text('네이버 로그인'),
                ),
              ),
              const SizedBox(height: 12),

              // 카카오 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFE812), // 카카오 노랑
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('카카오 로그인'),
                ),
              ),
              const SizedBox(height: 12),

              // 구글 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('구글 로그인'),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

