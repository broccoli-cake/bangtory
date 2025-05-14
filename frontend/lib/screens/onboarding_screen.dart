import 'package:flutter/material.dart';
import 'dart:async'; // 타이머에 필요
import 'login_screen.dart'; // 로그인 화면 import

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 뒤 로그인 화면으로 이동
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
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
        ],
      ),
    );
  }
}
