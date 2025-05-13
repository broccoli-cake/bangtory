import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          //  배경 그라데이션
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
            bottom: 40.0, // 화면 아래에 잘리지 않게 띄움
            right: -screenWidth * 0.1,  // 화면 오른쪽 밖으로 조금 잘리게
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                //  연한색 원
                Container(
                  width: screenWidth * 0.8,  //크기 0.7->0.8
                  height: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5), // 그라데이션보다 더 연한 핑크
                    shape: BoxShape.circle,
                  ),
                ),
                //  원 안에 별
                Positioned(
                  top: screenWidth * 0.06,
                  right: screenWidth * 0.08,
                  child: Icon(
                    Icons.star_rate_rounded,
                    size: screenWidth * 0.45,
                    color: Color(0xFFED8585), // 진한 빨강
                  ),
                ),
              ],
            ),
          ),

          //  텍스트 (조정 가능하도록 Padding → Positioned 변경)
          Positioned(
            top: 200, // 텍스트 위치 조정하려면 이 숫자 바꾸기!
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
