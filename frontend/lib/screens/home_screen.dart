// home_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/bathroom_reserve_screen.dart';
import 'package:frontend/screens/dish_washing.dart';
import 'package:frontend/screens/trash_screen.dart';
import 'package:frontend/screens/visit_reserve_screen.dart';
import 'cleaning_duty_screen.dart';   // ⬅︎ 새 화면 import
import 'package:frontend/settings/setting_home.dart';

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
  List<String> participants = [];

  /* ----------------------- 참여자 관련 로직 ----------------------- */
  void _addParticipant(String name) {
    setState(() => participants.add(name));
  }

  void _showAddParticipantDialog() {
    String newName = '';
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('참여자 추가'),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: '이름 입력'),
              onChanged: (v) => newName = v,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newName
                      .trim()
                      .isNotEmpty) _addParticipant(newName.trim());
                  Navigator.pop(context);
                },
                child: const Text('추가'),
              ),
            ],
          ),
    );
  }

  /* ----------------------- UI ----------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
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
              showGeneralDialog(
                context: context,
                barrierLabel: "알림",
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.5),
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, anim1, anim2) {
                  return const SizedBox();
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: anim1,
                      curve: Curves.easeOut,
                    )),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: Column(
                          children: [
                            // 제목 + 닫기 버튼
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "알림",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            // 알림이 없다는 메시지 중앙 표시     임시로!
                            Expanded(
                              child: Center(
                                child: Text(
                                  "알림이 없습니다.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },

          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              /* ---------- 참여자 카드 ---------- */
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children:
                      participants
                          .map((name) => _buildParticipant(name))
                          .toList(),
                    ),
                  ],
                ),
              ),
              /* ---------- 탭 스위치 ---------- */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleButton('집안일', isChoreSelected, () {
                    setState(() => isChoreSelected = true);
                  }),
                  const SizedBox(width: 16),
                  _buildToggleButton('예약', !isChoreSelected, () {
                    setState(() => isChoreSelected = false);
                  }),
                ],
              ),
              const SizedBox(height: 20),
              /* ---------- 카테고리 ---------- */
              if (isChoreSelected)
                Wrap(
                  spacing: 40,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTaskItem(Icons.cleaning_services, '청소'),
                    _buildTaskItem(Icons.delete_outline, '분리수거'),
                    _buildTaskItem(Icons.local_dining, '설거지'),
                    _buildTaskItem(Icons.add, '추가'),
                  ],
                )
              else
                Wrap(
                  spacing: 40,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTaskItem(Icons.bathtub, '욕실'),
                    _buildTaskItem(Icons.local_laundry_service, '세탁기'),
                    _buildTaskItem(Icons.emoji_people, '방문객'),
                    _buildTaskItem(Icons.add, '추가'),
                  ],
                ),
              const SizedBox(height: 24),
              /* ---------- 오늘 할 일 카드 ---------- */
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                    '오늘 할 일', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  /* ------------------ 위젯 빌더 ------------------ */
  Widget _buildProfileSection() =>
      ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.pinkAccent,
          child: const Icon(Icons.face, color: Colors.white),
        ),
        title: Text(widget.userName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('방장'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _showAddParticipantDialog,
        ),
      );

  Widget _buildParticipant(String name) =>
      Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _getColorForName(name),
            child: const Icon(Icons.face, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      );

  Color _getColorForName(String name) {
    final colors = [
      Colors.yellow,
      Colors.lightGreen,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
    ];
    int index = name.hashCode % colors.length;
    return colors[index];
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFFFA2E55) : Colors.grey,
            fontSize: 16,
          ),
        ),
      );

  Widget _buildTaskItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == '청소') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CleaningDutyScreen()),
          );
        } else if (label == '분리수거') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const trashscreen()),
          );
        }
        else if (label == '설거지') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const dishwashing()),
          );
          // 필요한 다른 라벨도 여기에 추가 가능
        }
        else if (label == '욕실') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BathroomReserve()),
          );
          // 필요한 다른 라벨도 여기에 추가 가능
        }
        else if (label == '방문객') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VisitReserve()),
          );
          // 필요한 다른 라벨도 여기에 추가 가능
        }
      },
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.black54),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }


  Widget _buildBottomNavBar(BuildContext context) =>
      BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFA2E55),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: '캘린더'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: '시간표'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        onTap: (index) {
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
      );
}
