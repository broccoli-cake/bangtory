// lib/screens/home_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // 카테고리 로드
  Future<void> _loadCategories() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadChoreCategories();
    await appState.loadReservationCategories();
  }

  // 초대코드 생성 - 백엔드와 연동
  Future<void> _showInviteCodeDialog() async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      final inviteCode = await appState.generateInviteCode();

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초대 코드 생성 실패: $e')),
      );
    }
  }

  // 카테고리 추가 다이얼로그 (백엔드 연동)
  void _showAddCategoryDialog(bool isChore) {
    String selectedIcon = '⭐'; // 이모지로 변경
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('${isChore ? "집안일" : "예약"} 카테고리 추가'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '카테고리 이름'),
                ),
                const SizedBox(height: 10),
                const Text('아이콘 선택:'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    '⭐', '🏠', '💡', '🐾', '☕', '📶', '🔧', '📱', '🎮', '📚'
                  ].map((icon) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedIcon == icon ? Colors.blue : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    try {
                      final appState = Provider.of<AppState>(context, listen: false);

                      if (isChore) {
                        await appState.createChoreCategory(
                          name: name,
                          icon: selectedIcon,
                        );
                      } else {
                        await appState.createReservationCategory(
                          name: name,
                          icon: selectedIcon,
                        );
                      }

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$name 카테고리가 추가되었습니다.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('카테고리 추가 실패: $e')),
                      );
                    }
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

  // 카테고리 삭제 확인 (백엔드 연동)
  void _confirmDeleteCategory(bool isChore, Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('${category['name']} 카테고리를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final appState = Provider.of<AppState>(context, listen: false);

                if (isChore) {
                  await appState.deleteChoreCategory(category['_id']);
                } else {
                  await appState.deleteReservationCategory(category['_id']);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${category['name']} 카테고리가 삭제되었습니다.')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('카테고리 삭제 실패: $e')),
                );
              }
            },
            child: const Text('삭제'),
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
            Wrap(
              spacing: 40,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                ..._buildDefaultTasks(isChoreSelected),
                ..._buildUserTasks(isChoreSelected),
                _buildAddTaskButton(isChoreSelected),
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
              child: const Text('오늘 할 일', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
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
    subtitle: Consumer<AppState>(
      builder: (context, appState, child) {
        return Text(appState.currentRoom?.isOwner == true ? '방장' : '멤버');
      },
    ),
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

  // 사용자 정의 카테고리 빌드 (백엔드 데이터 사용)
  List<Widget> _buildUserTasks(bool isChore) {
    return [
      Consumer<AppState>(
        builder: (context, appState, child) {
          final categories = isChore
              ? appState.choreCategories.where((cat) => cat['type'] == 'custom').toList()
              : appState.reservationCategories.where((cat) => cat['type'] == 'custom').toList();

          return Wrap(
            spacing: 40,
            runSpacing: 24,
            children: categories.map((category) {
              return GestureDetector(
                onLongPress: () => _confirmDeleteCategory(isChore, category),
                child: Column(
                  children: [
                    Text(category['icon'], style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
                    Text(category['name']),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    ];
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
              context, MaterialPageRoute(builder: (_) => const trashscreen()));
        } else if (label == '설거지') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const dishwashing()));
        } else if (label == '욕실') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BathScheduleScreen()));
        } else if (label == '방문객') {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const VisitReserve()));
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