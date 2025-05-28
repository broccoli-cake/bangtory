/* 현재 방 생성-홈 연결 상태
   ***프로필 설정화면에서 "닉네임 반영하기" 기능 부족
   아이콘 배치 수정 필요!!! 카테고리, 프로필 부분
   현재는 임시로 참여자1,2, 가 뜨는 상황- 이는 추후 실제 참여자로 수정 필요
   추가버튼 누르면 카테고리 추가기능 필요 (사용자 정의 아이콘 선택 가능)
   삭제 기능 (길게 누르면 삭제 등)
   알림창 필요 */


import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String roomName;
  final String userName;

  const HomeScreen({
    super.key,
    required this.roomName,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isChoreSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // 아주 연한 회색 섞인 화이트
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.roomName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // 추후 알림창 구현 예정
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // 참여자 목록
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildProfile(icon: Icons.person, name: widget.userName, isLeader: true),
                    const SizedBox(width: 12),
                    _buildProfile(icon: Icons.person, name: "참여자1"),   //실제 참여자로 반영할 필요 있음
                    _buildProfile(icon: Icons.person, name: "참여자2"),
                    // 추가 참여자들
                  ],
                ),
              ),

              // 집안일 / 예약 선택 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleButton("집안일", isChoreSelected, () {
                    setState(() {
                      isChoreSelected = true;
                    });
                  }),
                  const SizedBox(width: 16),
                  _buildToggleButton("예약", !isChoreSelected, () {
                    setState(() {
                      isChoreSelected = false;
                    });
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // 카테고리들
              if (isChoreSelected)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTaskItem(Icons.cleaning_services, "청소"),
                        _buildTaskItem(Icons.delete_outline, "분리수거"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTaskItem(Icons.local_dining, "설거지"),
                        _buildTaskItem(Icons.add, "추가"),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTaskItem(Icons.bathtub, "욕실"),
                        _buildTaskItem(Icons.local_laundry_service, "세탁기"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTaskItem(Icons.emoji_people, "방문객"),
                        _buildTaskItem(Icons.add, "추가"),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // 오늘 할 일 (모양만)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "오늘 할 일",        //추후 구현
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildProfile({required IconData icon, String? name, bool isLeader = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFFA2E55),
          child: Icon(icon, color: Colors.white),
        ),
        if (name != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              name,
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Color(0xFFFA2E55) : Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTaskItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.black54),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // 홈
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFFFA2E55),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: '시간표'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
      ],
      onTap: (index) {
        // 추후 각 index별로 이동 구현 예정
      },
    );
  }
}
