import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/icon_utils.dart';
import 'dynamic_chore_screen.dart';
import 'dynamic_reservation_screen.dart';
import 'package:frontend/settings/setting_home.dart';
import 'package:frontend/settings/room/calendar.dart' as calendar_room;
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/screens/full_schedule_screen.dart';
import '../screens/notification_screen.dart';

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
  late String userName;
  bool isChoreSelected = true;


  List<String> participants = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadRoomMembers();
    _loadUserProfile(); // 프로필 정보 로드 추가
    _loadTodaySchedules(); // 오늘 일정 로드 추가
  }

  Future<void> _loadCategories() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadChoreCategories();
    await appState.loadReservationCategories();
  }

  Future<void> _loadRoomMembers() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadRoomMembers();
  }

  // 프로필 정보 로드 추가
  Future<void> _loadUserProfile() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadUserProfile();
  }

  // 오늘 일정 로드 수정
  Future<void> _loadTodaySchedules() async {
    final appState = Provider.of<AppState>(context, listen: false);

    // 오늘 집안일 일정 로드 - 시간 범위를 더 넓게 설정
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    print('오늘 날짜 범위: ${startOfDay} ~ ${endOfDay}'); // 디버깅용

    await appState.loadChoreSchedules(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    // 예약 일정 로드
    await appState.loadReservationSchedules();

    // 모든 카테고리의 현재 주 예약 로드
    for (final category in appState.reservationCategories) {
      if (category['isVisitor'] != true) {
        await appState.loadCategoryReservations(category['_id']);
      }
    }

    // 방문객 예약도 로드
    await appState.loadVisitorReservations();

    print('로드된 집안일 일정 수: ${appState.choreSchedules.length}'); // 디버깅용
    print('로드된 방문객 예약 수: ${appState.visitorReservations.length}'); // 디버깅용
  }

  // 카테고리별 아이콘 매핑 (이모지 → 기본 아이콘)
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

      // 추가 가능한 아이콘들
      '주방': Icons.kitchen,
      '거실': Icons.weekend,
      '방': Icons.bed,
      '화장실': Icons.wc,
      '발코니': Icons.balcony,
      '정원': Icons.grass,
      '차고': Icons.garage,
      '운동': Icons.fitness_center,
      '공부': Icons.school,
      '회의': Icons.meeting_room,
      '음식': Icons.restaurant,
      '쇼핑': Icons.shopping_cart,
      '의료': Icons.medical_services,
      '여행': Icons.flight,
      '업무': Icons.work,
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

  // 동적 카테고리 아이템 빌드 (IconUtils 사용)
  Widget _buildCategoryItem(Map<String, dynamic> category, bool isChore) {
    final categoryName = category['name'];
    final categoryIcon = category['icon']; // 아이콘 이름이 저장됨
    final isDefault = category['type'] == 'default';

    // 아이콘 결정 순서: 저장된 아이콘 이름 → 카테고리 이름 기반 기본 아이콘 → 기본 아이콘
    IconData iconData;
    if (categoryIcon != null && categoryIcon.isNotEmpty) {
      iconData = IconUtils.getIconData(categoryIcon);
    } else {
      iconData = IconUtils.getDefaultIconForCategory(categoryName);
    }

    return GestureDetector(
      onTap: () => _navigateToScreen(category, isChore),
      onLongPress: isDefault ? null : () => _confirmDeleteCategory(isChore, category),
      child: Column(
        children: [
          Icon(
            iconData,
            size: 35,
            color: Colors.black54,
          ),
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

  // 카테고리 추가 다이얼로그 (IconUtils 사용) - 카테고리 추가 후 알림 개수 업데이트
  void _showAddCategoryDialog(bool isChore) {
    String selectedIconName = 'category';
    TextEditingController nameController = TextEditingController();

    // 카테고리 타입에 맞는 아이콘 목록 가져오기
    final availableIcons = isChore
        ? IconUtils.getChoreIcons()
        : IconUtils.getReservationIcons();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('${isChore ? "집안일" : "예약"} 카테고리 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '카테고리 이름'),
                  ),
                  const SizedBox(height: 16),
                  const Text('아이콘 선택:'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.maxFinite,
                    height: 200,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final iconName = availableIcons.keys.elementAt(index);
                        final iconData = availableIcons[iconName]!;
                        final isSelected = selectedIconName == iconName;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIconName = iconName;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFA2E55) : Colors.grey,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected ? const Color(0xFFFA2E55).withOpacity(0.1) : null,
                            ),
                            child: Icon(
                              iconData,
                              size: 28,
                              color: isSelected ? const Color(0xFFFA2E55) : Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA2E55),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    try {
                      final appState = Provider.of<AppState>(context, listen: false);

                      if (isChore) {
                        await appState.createChoreCategory(
                          name: name,
                          icon: selectedIconName,
                        );
                      } else {
                        await appState.createReservationCategory(
                          name: name,
                          icon: selectedIconName,
                        );
                      }

                      // 성공 후 알림 개수 업데이트
                      await appState.loadUnreadNotificationCount();

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

  // 오늘의 할 일 가져오기 (집안일 + 예약) - 최종 수정 버전
  List<Map<String, dynamic>> _getTodayTasks() {
    final appState = Provider.of<AppState>(context, listen: false);
    final today = DateTime.now();
    final todayWeekday = today.weekday % 7; // 일요일=0, 월요일=1, ..., 토요일=6
    final currentUserId = appState.currentUser?.id;

    List<Map<String, dynamic>> todayTasks = [];

    print('=== 오늘 할 일 분석 시작 ===');
    print('현재 사용자 ID: $currentUserId');
    print('오늘 요일: $todayWeekday (${today.weekday})');

    if (currentUserId == null) return todayTasks;

    // 1. 오늘의 집안일 일정 분석
    print('\n=== 집안일 일정 분석 ===');
    final todayChores = appState.choreSchedules.where((schedule) {
      final scheduleDate = DateTime.tryParse(schedule['date']?.toString() ?? '');
      if (scheduleDate == null) return false;

      final isSameDay = scheduleDate.year == today.year &&
          scheduleDate.month == today.month &&
          scheduleDate.day == today.day;

      // 담당자 확인 - userId로 직접 비교 (백엔드에서 userId를 직접 저장하도록 수정함)
      final assignedTo = schedule['assignedTo'];
      bool isMyTask = false;

      print('\n집안일 일정: ${schedule['category']?['name']}');
      print('  - 날짜: $scheduleDate');
      print('  - 같은 날: $isSameDay');
      print('  - assignedTo: $assignedTo');

      if (assignedTo != null) {
        // assignedTo가 이제 직접 userId이므로 간단한 비교
        if (assignedTo is Map<String, dynamic>) {
          // 만약 여전히 객체 형태라면 _id를 확인
          final assignedUserId = assignedTo['_id']?.toString();
          isMyTask = assignedUserId == currentUserId;
          print('  - 객체 형태: $assignedUserId vs $currentUserId = $isMyTask');
        } else {
          // 직접 문자열로 저장된 경우
          isMyTask = assignedTo.toString() == currentUserId;
          print('  - 직접 비교: ${assignedTo.toString()} vs $currentUserId = $isMyTask');
        }
      }

      print('  - 최종 내 일정 여부: $isMyTask');

      return isSameDay && isMyTask;
    }).map((schedule) => {
      ...schedule,
      'type': 'chore',
      'time': '하루종일',
      'title': schedule['category']?['name'] ?? '집안일',
      'categoryIcon': schedule['category']?['icon'],
    });

    // 2. 일반 예약 분석
    print('\n=== 일반 예약 분석 ===');
    List<Map<String, dynamic>> todayReservations = [];

    for (final categoryId in appState.categoryReservations.keys) {
      final reservations = appState.categoryReservations[categoryId] ?? [];

      print('\n카테고리 ID: $categoryId');
      print('예약 수: ${reservations.length}');

      final myTodayReservations = reservations.where((reservation) {
        final dayOfWeek = reservation['dayOfWeek'];
        final reservedBy = reservation['reservedBy'];

        bool isToday = false;
        if (dayOfWeek != null) {
          final dayOfWeekInt = dayOfWeek is int ? dayOfWeek : int.tryParse(dayOfWeek.toString());
          isToday = dayOfWeekInt == todayWeekday;
        }

        // 예약자 확인 - userId로 직접 비교
        bool isMyReservation = false;

        print('\n일반 예약: ${reservation['category']?['name']}');
        print('  - 요일: $dayOfWeek');
        print('  - 오늘: $isToday');
        print('  - reservedBy: $reservedBy');

        if (reservedBy != null) {
          if (reservedBy is Map<String, dynamic>) {
            // 만약 여전히 객체 형태라면 _id를 확인
            final reservedUserId = reservedBy['_id']?.toString();
            isMyReservation = reservedUserId == currentUserId;
            print('  - 객체 형태: $reservedUserId vs $currentUserId = $isMyReservation');
          } else {
            // 직접 문자열로 저장된 경우
            isMyReservation = reservedBy.toString() == currentUserId;
            print('  - 직접 비교: ${reservedBy.toString()} vs $currentUserId = $isMyReservation');
          }
        }

        print('  - 최종 내 예약 여부: $isMyReservation');

        return isToday && isMyReservation;
      }).map((reservation) => {
        ...reservation,
        'type': 'reservation',
        'time': '${reservation['startHour'] ?? 0}:00 - ${reservation['endHour'] ?? 0}:00',
        'title': reservation['category']?['name'] ?? '예약',
        'categoryIcon': reservation['category']?['icon'],
      });

      todayReservations.addAll(myTodayReservations);
    }

    // 3. 방문객 예약 분석
    print('\n=== 방문객 예약 분석 ===');
    final myTodayVisitorReservations = appState.visitorReservations.where((reservation) {
      if (reservation['specificDate'] == null) return false;

      final reservationDate = DateTime.tryParse(reservation['specificDate'].toString());
      if (reservationDate == null) return false;

      final isSameDay = reservationDate.year == today.year &&
          reservationDate.month == today.month &&
          reservationDate.day == today.day;

      final reservedBy = reservation['reservedBy'];
      bool isMyReservation = false;

      print('\n방문객 예약: ${reservation['category']?['name']}');
      print('  - 날짜: $reservationDate');
      print('  - 같은 날: $isSameDay');
      print('  - reservedBy: $reservedBy');

      if (reservedBy != null) {
        if (reservedBy is Map<String, dynamic>) {
          // 만약 여전히 객체 형태라면 _id를 확인
          final reservedUserId = reservedBy['_id']?.toString();
          isMyReservation = reservedUserId == currentUserId;
          print('  - 객체 형태: $reservedUserId vs $currentUserId = $isMyReservation');
        } else {
          // 직접 문자열로 저장된 경우
          isMyReservation = reservedBy.toString() == currentUserId;
          print('  - 직접 비교: ${reservedBy.toString()} vs $currentUserId = $isMyReservation');
        }
      }

      print('  - 최종 내 예약 여부: $isMyReservation');

      return isSameDay && isMyReservation;
    }).map((reservation) => {
      ...reservation,
      'type': 'visitor',
      'time': '${reservation['startHour'] ?? 0}:00 - ${reservation['endHour'] ?? 0}:00',
      'title': reservation['category']?['name'] ?? '방문객',
      'categoryIcon': reservation['category']?['icon'],
    });

    todayReservations.addAll(myTodayVisitorReservations);

    // 모든 할 일 합치기
    todayTasks.addAll(todayChores);
    todayTasks.addAll(todayReservations);

    print('\n=== 최종 결과 ===');
    print('집안일 할 일: ${todayChores.length}개');
    print('예약 할 일: ${todayReservations.length}개');
    print('총 오늘 할 일: ${todayTasks.length}개');

    // 시간순 정렬
    todayTasks.sort((a, b) {
      if (a['type'] == 'chore' && b['type'] != 'chore') return 1;
      if (b['type'] == 'chore' && a['type'] != 'chore') return -1;

      if (a['type'] != 'chore' && b['type'] != 'chore') {
        final aStartHour = a['startHour'] ?? 0;
        final bStartHour = b['startHour'] ?? 0;
        return aStartHour.compareTo(bStartHour);
      }

      return 0;
    });

    return todayTasks;
  }

  // 오늘 할 일 아이템 빌드
  Widget _buildTodayTaskItem(Map<String, dynamic> task) {
    final type = task['type'];
    final title = task['title'];
    final time = task['time'];
    final categoryIcon = task['categoryIcon'];
    final isCompleted = task['isCompleted'] == true;
    final status = task['status'] ?? 'approved';

    // 타입별 색상과 아이콘
    Color color;
    IconData icon;

    if (type == 'chore') {
      color = Colors.redAccent;
      icon = categoryIcon != null ? IconUtils.getIconData(categoryIcon) : Icons.cleaning_services;
    } else if (type == 'visitor') {
      color = Colors.orangeAccent;
      icon = categoryIcon != null ? IconUtils.getIconData(categoryIcon) : Icons.emoji_people;
    } else {
      color = Colors.lightGreen;
      icon = categoryIcon != null ? IconUtils.getIconData(categoryIcon) : Icons.event_available;
    }

    // 상태에 따른 색상 조정
    if (type == 'chore' && isCompleted) {
      color = Colors.grey;
    } else if (type == 'visitor' && status == 'pending') {
      color = Colors.orangeAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    if (type == 'chore' && isCompleted)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '완료',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    if (type == 'visitor' && status == 'pending')
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '승인대기',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // 홈 화면에서는 완료만 가능, 완료된 일정은 체크 아이콘만 표시 (수정됨)
          if (type == 'chore')
            isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                : IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () async {
                final appState = Provider.of<AppState>(context, listen: false);
                try {
                  await appState.completeChoreSchedule(task['_id']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('일정이 완료되었습니다.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('완료 처리 실패: $e')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  // 프로필 이미지별 색상 매핑 (토마토 숙성 단계)
  Color _getProfileColor(String? profileImageUrl) {
    switch (profileImageUrl) {
      case '/images/profile1.png':
        return const Color(0xFF4CAF50);
      case '/images/profile2.png':
        return const Color(0xFF8BC34A);
      case '/images/profile3.png':
        return const Color(0xFFFFEB3B);
      case '/images/profile4.png':
        return const Color(0xFFFF9800);
      case '/images/profile5.png':
        return const Color(0xFFFF5722);
      case '/images/profile6.png':
        return const Color(0xFFFA2E55);
      default:
        return const Color(0xFFFA2E55);
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
        title: Consumer<AppState>(
          builder: (context, appState, child) {
            return Text(
              appState.currentRoom?.roomName ?? widget.roomName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              // 모든 데이터 새로고침
              await _loadCategories();
              await _loadRoomMembers();
              await _loadUserProfile();
              await _loadTodaySchedules();
            },
          ),
          Consumer<AppState>(
            builder: (context, appState, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                  ),
                  if (appState.unreadNotificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFA2E55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${appState.unreadNotificationCount > 99 ? '99+' : appState.unreadNotificationCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileSection(), // 통합된 프로필 섹션
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 집안일 / 예약 토글 버튼
                _buildToggleButton('집안일', isChoreSelected, () {
                  setState(() => isChoreSelected = true);
                }),
                const SizedBox(width: 30),
                _buildToggleButton('예약', !isChoreSelected, () {
                  setState(() => isChoreSelected = false);
                }),
              ],
            ),

            /*const SizedBox(height: 20),     //기존 코드
            // 할 일(카테고리) 목록
            Wrap(                   // 기존 카테고리 코드
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
            ), */
            const SizedBox(height: 20),
            if (isChoreSelected) //카테고리 코드 중복.
              Wrap(
                spacing: 40,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _goToCleaning,
                    child: Column(
                      children: const [
                        Icon(Icons.cleaning_services, size: 32,
                            color: Colors.black54),
                        SizedBox(height: 4),
                        Text('청소'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToTrash,
                    child: Column(
                      children: const [
                        Icon(Icons.delete_outline, size: 32,
                            color: Colors.black54),
                        SizedBox(height: 4),
                        Text('분리수거'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToDishwashing,
                    child: Column(
                      children: const [
                        Icon(Icons.local_dining, size: 32,
                            color: Colors.black54),
                        SizedBox(height: 4),
                        Text('설거지'),
                      ],
                    ),
                  ),
                  ..._buildUserTasks(isChoreSelected),
                  // 사용자가 추가한 카테고리  //오늘 할일 반영 ㅗ위해 여기 수정해봄!!
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
                  ..._buildUserTasks(isChoreSelected),
                  // 사용자가 추가한 카테고리   ////////////////////예약은 추가 안됨 이거 확인해보기
                  _buildAddTaskButton(false),
                ],
              ), // 오늘할일을 위한 카테고리 코드


            const SizedBox(height: 24),
            // 오늘 할 일 섹션 - 수정된 부분
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  final todayTasks = _getTodayTasks();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '오늘 할 일',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${todayTasks.length}개',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (todayTasks.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_available,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '오늘 할 일이 없습니다',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: todayTasks.map((task) => _buildTodayTaskItem(task)).toList(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context), //
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // 멤버 정렬: 본인이 맨 앞, 그 다음은 방 입장 순서대로
        final sortedMembers = List<Map<String, dynamic>>.from(appState.roomMembers);
        final currentUserId = appState.currentUser?.id;

        sortedMembers.sort((a, b) {
          final aUserId = a['userId']?.toString();
          final bUserId = b['userId']?.toString();

          // 본인이면 맨 앞으로
          if (aUserId == currentUserId && bUserId != currentUserId) return -1;
          if (bUserId == currentUserId && aUserId != currentUserId) return 1;

          // 둘 다 본인이 아니면 입장한 순서대로
          DateTime? aTime;
          DateTime? bTime;

          // joinedAt 시도
          if (a['joinedAt'] != null) {
            aTime = DateTime.tryParse(a['joinedAt'].toString());
          }
          if (b['joinedAt'] != null) {
            bTime = DateTime.tryParse(b['joinedAt'].toString());
          }

          // joinedAt이 없으면 createdAt 시도
          if (aTime == null && a['createdAt'] != null) {
            aTime = DateTime.tryParse(a['createdAt'].toString());
          }
          if (bTime == null && b['createdAt'] != null) {
            bTime = DateTime.tryParse(b['createdAt'].toString());
          }

          // 둘 다 있으면 비교 (먼저 입장한 순서)
          if (aTime != null && bTime != null) {
            return aTime.compareTo(bTime);
          }

          // 시간 정보가 없으면 _id로 비교
          final aId = a['_id']?.toString() ?? '';
          final bId = b['_id']?.toString() ?? '';
          return aId.compareTo(bId);
        });

        return Container(
          height: 70,
          child: Row(
            children: [
              // 멤버들
              if (sortedMembers.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sortedMembers.length,
                    itemBuilder: (context, index) {
                      final member = sortedMembers[index];
                      final isCurrentUser = member['userId'].toString() == currentUserId;
                      final isOwner = member['isOwner'] == true;
                      final profileImageUrl = member['profileImageUrl'];

                      return Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: _getProfileColor(profileImageUrl),
                                  child: Icon(
                                    Icons.face,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                // 방장 표시
                                if (isOwner)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                                // 나 표시 (방장이 아닌 경우)
                                if (isCurrentUser && !isOwner)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFA2E55),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.face,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: SizedBox(
                                width: 65,
                                child: Text(
                                  member['nickname']?.toString() ?? '멤버',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCurrentUser ? const Color(0xFFFA2E55) : Colors.grey[700],
                                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // 초대 버튼 (항상 표시)
              Container(
                margin: EdgeInsets.only(left: sortedMembers.isNotEmpty ? 8 : 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _showInviteCodeDialog,
                      child: Container(
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.share,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
          MaterialPageRoute(builder: (_) => const calendar_room.CalendarScreen()),
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
          MaterialPageRoute(builder: (_) => const ChatRoomScreenWithSocket()),
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