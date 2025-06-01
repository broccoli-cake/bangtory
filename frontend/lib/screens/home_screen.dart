

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/dish_washing.dart';
import 'trash_screen.dart';
import 'package:frontend/screens/cleaning_duty_screen.dart';
import 'bathroom_reserve_screen.dart';
import 'visit_reserve_screen.dart';
import 'package:frontend/settings/setting_home.dart';
import 'package:frontend/settings/room/calendar.dart';
import 'package:frontend/screens/full_schedule_screen.dart';
import 'package:frontend/screens/chat_screen.dart';

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
  //카테고리 추가 관련
  List<Map<String, dynamic>> userChoreCategories = [];
  List<Map<String, dynamic>> userReserveCategories = [];

  //할일 등록 투두리스트
  List<Map<String, dynamic>> dishwashingDuties = [];
  List<Map<String, dynamic>> cleaningDuties = [];
  List<Map<String, dynamic>> trashDuties = [];

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
  void _showAddCategoryDialog(bool isChore) {
    IconData selectedIcon = Icons.star;
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('카테고리 추가'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '카테고리 이름'),
                ),
                const SizedBox(height: 10),
                DropdownButton<IconData>(
                  value: selectedIcon,
                  items: const [
                    Icons.star,
                    Icons.home,
                    Icons.lightbulb,
                    Icons.pets,
                    Icons.local_cafe,
                    Icons.wifi,
                  ].map((icon) {
                    return DropdownMenuItem(
                      value: icon,
                      child: Icon(icon),
                    );
                  }).toList(),
                  onChanged: (icon) {
                    if (icon != null) {
                      setStateDialog(() {
                        selectedIcon = icon;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      if (isChore) {
                        userChoreCategories.add({
                          'icon': selectedIcon,
                          'label': name,
                        });
                      } else {
                        userReserveCategories.add({
                          'icon': selectedIcon,
                          'label': name,
                        });
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('추가'),
              ),
            ],
          );
        },
      ),
    );
  }


  void _confirmDeleteCategory(bool isChore, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('해당 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isChore) {
                  userChoreCategories.removeAt(index);
                } else {
                  userReserveCategories.removeAt(index);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _goToDishwashing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Dishwashing()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        dishwashingDuties.add({
          'date': result['date'],
          'person': result['person'],
          'done': false,
        });
      });
    }
  }

  Future<void> _goToCleaning() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CleaningDutyScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        cleaningDuties.add({
          'date': result['date'],
          'person': result['person'],
          'done': false,
        });
      });
    }
  }
  Future<void> _goToTrash() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TrashDutyScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        trashDuties.add({
          'date': result['date'],
          'person': result['person'],
          'done': false,
        });
      });
    }
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
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileSection(), // 사용자 프로필 표시
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 집안일 / 예약 토글 버튼
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
            // 할 일(카테고리) 목록
            Wrap(
              spacing: 40,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [ // 기본 카테고리
                ..._buildUserTasks(isChoreSelected),    // 사용자가 추가한 카테고리
                 // 추가 버튼
              ],
            ),
            const SizedBox(height: 20),
            if (isChoreSelected)
              Wrap(
                spacing: 40,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _goToCleaning,
                    child: Column(
                      children: const [
                        Icon(Icons.cleaning_services, size: 32, color: Colors.black54),
                        SizedBox(height: 4),
                        Text('청소'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToTrash,
                    child: Column(
                      children: const [
                        Icon(Icons.delete_outline, size: 32, color: Colors.black54),
                        SizedBox(height: 4),
                        Text('분리수거'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToDishwashing,
                    child: Column(
                      children: const [
                        Icon(Icons.local_dining, size: 32, color: Colors.black54),
                        SizedBox(height: 4),
                        Text('설거지'),
                      ],
                    ),
                  ),
                  _buildAddTaskButton(true),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('오늘 할 일', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  if (dishwashingDuties.isNotEmpty)
                    Column(
                      children: dishwashingDuties.map((duty) {
                        final dateStr = duty['date'].toString().split(' ')[0];
                        return ListTile(
                          leading: const Icon(Icons.local_dining),
                          title: Text('$dateStr - ${duty['person']} 설거지하기'),
                          trailing: Checkbox(
                            value: duty['done'],
                            onChanged: (val) {
                              setState(() {
                                duty['done'] = val ?? false;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('설거지 일정이 없습니다.'),
                    ),

            if (cleaningDuties.isNotEmpty)
                    Column(
                      children: cleaningDuties.map((duty) {
                        final dateStr = duty['date'].toString().split(' ')[0];
                        return ListTile(
                          leading: const Icon(Icons.cleaning_services),
                          title: Text('$dateStr - ${duty['person']} 청소하기'),
                          trailing: Checkbox(
                            value: duty['done'],
                            onChanged: (val) {
                              setState(() {
                                duty['done'] = val ?? false;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('청소 일정이 없습니다.'),
                    ),
                  if (trashDuties.isNotEmpty)
                    Column(
                      children: trashDuties.map((duty) {
                        final dateStr = duty['date'].toString().split(' ')[0];
                        return ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: Text('$dateStr - ${duty['person']} 분리수거하기'),
                          trailing: Checkbox(
                            value: duty['done'],
                            onChanged: (val) {
                              setState(() {
                                duty['done'] = val ?? false;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('분리수거 일정이 없습니다.'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context), // ✅ 이 줄 추가됨
    );
  }

  Widget _buildProfileSection() => ListTile(
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

  List<Widget> _buildDefaultTasks(bool isChore) {
    if (isChore) {
      return [
        _buildTaskItem(Icons.cleaning_services, '청소'),
        _buildTaskItem(Icons.delete_outline, '분리수거'),
        _buildTaskItem(Icons.local_dining, '설거지'),
      ];
    } else {
      return [
        _buildTaskItem(Icons.bathtub, '욕실'),
        _buildTaskItem(Icons.local_laundry_service, '세탁기'),
        _buildTaskItem(Icons.emoji_people, '방문객'),
      ];
    }
  }

  List<Widget> _buildUserTasks(bool isChore) {
    final categories = isChore ? userChoreCategories : userReserveCategories;
    return List.generate(categories.length, (index) {
      final item = categories[index];
      return GestureDetector(
        onLongPress: () => _confirmDeleteCategory(isChore, index),
        child: Column(
          children: [
            Icon(item['icon'], size: 32, color: Colors.black54),
            const SizedBox(height: 4),
            Text(item['label']),
          ],
        ),
      );
    });
  }

  Widget _buildAddTaskButton(bool isChore) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(isChore),
      child: Column(
        children: const [
          Icon(Icons.add, size: 32, color: Colors.black54),
          SizedBox(height: 4),
          Text('추가'),
        ],
      ),
    );
  }

  Widget _buildTaskItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == '청소') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CleaningDutyScreen()));
        } else if (label == '분리수거') {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const TrashDutyScreen()));
        } else if (label == '설거지') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const Dishwashing()));
        } else if (label == '욕실') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BathScheduleScreen()));
        } else if (label == '방문객') {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const VisitReserve()));
        } else if (label == '세탁기') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BathScheduleScreen()));
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



  Widget _buildBottomNavBar(BuildContext context) => BottomNavigationBar(
    currentIndex: 2,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: const Color(0xFFFA2E55),
    unselectedItemColor: Colors.grey,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
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
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatRoomScreen()));
      } else if (index == 1) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FullScheduleScreen()));
      }
    },
  );
}