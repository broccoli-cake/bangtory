import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/bathroom_reserve_screen.dart';
import 'package:frontend/screens/washer_reserve.dart';
import 'package:frontend/screens/dish_washing.dart';
import 'package:frontend/screens/trash_screen.dart';
import 'package:frontend/screens/visit_reserve_screen.dart';
import 'cleaning_duty_screen.dart';
import 'package:frontend/settings/setting_home.dart';
import 'package:frontend/settings/room/calendar.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/screens/full_schedule_screen.dart';

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

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  void _showInviteCodeDialog() {
    final inviteCode = _generateInviteCode();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('초대 코드'),
        content: SelectableText(
          inviteCode,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('초대 코드가 복사되었습니다')),
              );
            },
            child: const Text('복사'),
          ),
        ],
      ),
    );
  }

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
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileSection(),
            const SizedBox(height: 20),
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
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

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
          icon: const Icon(Icons.share),
          onPressed: _showInviteCodeDialog,
        ),
      );

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
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CleaningDutyScreen()));
        } else if (label == '분리수거') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const trashscreen()));
        } else if (label == '설거지') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const dishwashing()));
        } else if (label == '욕실') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BathScheduleScreen()));
        } else if (label == '방문객') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const VisitReserve()));
        } else if (label == '세탁기') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WasherReserveScreen()));
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
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          } else if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChatRoomScreen()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FullScheduleScreen()));
          }
        },
      );
}
