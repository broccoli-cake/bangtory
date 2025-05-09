//프로필 이미지 설정(갤러리 이동), 랜덤 닉네임 불러오기 기능 추가 필요!!!

import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0), //  전체적으로 아래로
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 텍스트
            Text(
              '안녕하세요!\n프로필을 만들어 주세요.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 50), //  더 큰 여백으로 이미지 아래로

            // 프로필 이미지   ..나중에 갤러리로 연결해서 이미지 편집기능 추가필요
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80, //더 크게
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 80, // 아이콘도 같이 키움
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[400],
                      child: Icon(Icons.edit, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // 닉네임 위 간격

            // 닉네임 입력창      .. 랜덤 닉네임 불러오기 기능 추가 필요
            TextField(     // 사용자가 텍스트 수정가능
              decoration: InputDecoration(
                hintText: '울퉁불퉁 토마토',
                filled: true,
                fillColor: Color(0xFFFFE4E1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),

            const Spacer(),

            // 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 다음 화면으로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
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