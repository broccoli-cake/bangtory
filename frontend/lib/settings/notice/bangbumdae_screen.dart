import 'package:flutter/material.dart';

class BangBumdaeScreen extends StatelessWidget {
  const BangBumdaeScreen({super.key});

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
          '방범대 소개',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '팀명: 방범대',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 12),
            Text(
              '• 방(Bang)’ + ‘범대(모임, 팀)’의 조합으로, 방토리를 사용하는 사용자들을 지키는 팀이라는 의미를 담고 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '방토리 (BangTori)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 12),
            Text(
              '• 룸메이트 생활 필수 앱: 청소, 공과금, 일정 공유까지 올인원 관리',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '• 방토리(BangTori)는 룸메이트 생활을 편리하게 관리하고, 함께하는 순간을 더욱 특별하게 만들어주는 플랫폼입니다.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
