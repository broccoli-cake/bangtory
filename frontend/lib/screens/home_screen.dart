import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import 'dynamic_chore_screen.dart'; // 추가
import 'dynamic_reservation_screen.dart'; // 추가
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

  Future<void> _loadCategories() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadChoreCategories();
    await appState.loadReservationCategories();
  }

  // 카테고리별 아이콘 매핑
  IconData getCategoryIcon(String categoryName) {
    final iconMap = {
      // 집안일 아이콘
      '청소': Icons.cleaning_services,
      '분리수거': Icons.delete_outline,
      '설거지': Icons.local_dining,

      // 예약 아이콘
      '욕실': Icons.bathtub,
      '세탁기': Icons.local_laundry_service,
      '방문객': Icons.emoji_people,
    };

    return iconMap[categoryName] ?? Icons.category;
  }

  // 카테고리별 화면 이동 처리
  void _navigateToScreen(Map<String, dynamic> category, bool isChore) {
    final categoryName = category['name'];

    if (isChore) {
      // 집안일 화면 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DynamicChoreScreen(category: category),
        ),
      );
    } else {
      // 예약 화면 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DynamicReservationScreen(category: category),
        ),
      );
    }
  }

  // 동적 카테고리 아이템 빌드
  Widget _buildCategoryItem(Map<String, dynamic> category, bool isChore) {
    final categoryName = category['name'];
    final categoryIcon = category['icon'];
    final isDefault = category['type'] == 'default';

    return GestureDetector(
      onTap: () => _navigateToScreen(category, isChore),
      onLongPress: isDefault ? null : () => _confirmDeleteCategory(isChore, category),
      child: Column(
        children: [
          // 이모지 아이콘이 있으면 사용, 없으면 기본 아이콘 사용
          categoryIcon.isNotEmpty
              ? Text(categoryIcon, style: const TextStyle(fontSize: 32))
              : Icon(getCategoryIcon(categoryName), size: 35, color: Colors.black54),
          const SizedBox(height: 10),
          Text(categoryName),
        ],
      ),
    );
  }

  // 카테고리 목록 동적 생성
  List<Widget> _buildCategoryItems(bool isChore) {
    final appState = Provider.of<AppState>(context, listen: false);
    final categories = isChore
        ? appState.choreCategories
        : appState.reservationCategories;

    // 기본 카테고리와 사용자 정의 카테고리를 모두 포함
    return categories.map<Widget>((category) {
      return _buildCategoryItem(category, isChore);
    }).toList();
  }

  // 초대코드 생성
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

  // 카테고리 추가 다이얼로그
  void _showAddCategoryDialog(bool isChore) {
    String selectedIcon = '⭐';
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
                            color: selectedIcon == icon ? Colors.pinkAccent : Colors.grey,
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

  // 카테고리 삭제 확인 (기본 카테고리는 삭제 불가)
  void _confirmDeleteCategory(bool isChore, Map<String, dynamic> category) {
    if (category['type'] == 'default') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기본 카테고리는 삭제할 수 없습니다.')),
      );
      return;
    }

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

  // 추가 버튼
  Widget _buildAddTaskButton(bool isChore) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(isChore),
      child: Column(
        children: const [
          Icon(Icons.add, size: 35, color: Colors.black54),
          SizedBox(height: 10),
          Text('추가'),
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
              // 알림 처리
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
                const SizedBox(width: 30),
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
                // Consumer를 사용하여 상태 변화 감지
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Wrap(
                      spacing: 40,
                      runSpacing: 24,
                      children: [
                        ..._buildCategoryItems(isChoreSelected),
                        _buildAddTaskButton(isChoreSelected),
                      ],
                    );
                  },
                ),
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
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FullScheduleScreen()),
        );
      } else if (index == 2) {
        // 현재 홈 화면이므로 아무것도 하지 않음
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatRoomScreen()),
        );
      } else if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
      }
    },
  );
}