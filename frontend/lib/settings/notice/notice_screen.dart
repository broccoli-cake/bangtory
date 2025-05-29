import 'package:flutter/material.dart';
import 'bangbumdae_screen.dart'; // 나중에 만들 화면 import

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

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
          '공지사항',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('방범대"를 소개합니다.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BangBumdaeScreen()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('업데이트 안내'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 나중에 업데이트 안내 화면 연결
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('문의하기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 문의하기 화면 연결 예정
            },
          ),
        ],
      ),
    );
  }
}
