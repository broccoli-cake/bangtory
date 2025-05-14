import 'package:flutter/material.dart';

class GoRoomScreen extends StatelessWidget {
  const GoRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 방 만들기 버튼
            Container(
              width: MediaQuery.of(context).size.width * 0.7, // 가로폭 70%
              height: 80, // 세로길이
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: () {
                  // TODO: 방 만들기 로직
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '방 만들기',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            // 방 들어가기 버튼
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: () {
                  // TODO: 방 입장 로직
                },
                icon: const Icon(Icons.meeting_room, color: Colors.white), // 문 아이콘
                label: const Text(
                  '방 들어가기',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

