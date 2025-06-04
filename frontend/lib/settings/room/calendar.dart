import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import '../../utils/icon_utils.dart'; // 추가
import '../../screens/home_screen.dart';
import '../../screens/chat_screen.dart';
import '../../screens/full_schedule_screen.dart';
import '../setting_home.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadData();
  }

  // 한국어 요일 매핑
  String _getKoreanWeekday(DateTime date) {
    const weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    return weekdays[date.weekday % 7];
  }

  // 날짜 포맷팅 (로케일 의존성 제거)
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일 ${_getKoreanWeekday(date)}';
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppState>(context, listen: false);

    // 집안일 및 예약 카테고리 로드
    await appState.loadChoreCategories();
    await appState.loadReservationCategories();

    // 집안일 일정 로드 (한 달 범위)
    final startDate = DateTime.now().subtract(const Duration(days: 30));
    final endDate = DateTime.now().add(const Duration(days: 30));

    await appState.loadChoreSchedules(
      startDate: startDate,
      endDate: endDate,
    );

    // 방문객 예약 로드
    await appState.loadVisitorReservations();

    // 상태 업데이트
    if (mounted) {
      setState(() {});
    }
  }

  // 특정 날짜의 이벤트 가져오기
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final appState = Provider.of<AppState>(context, listen: false);
    List<Map<String, dynamic>> events = [];

    // 집안일 일정 필터링
    final choreEvents = appState.choreSchedules.where((schedule) {
      final scheduleDate = DateTime.parse(schedule['date']);
      return isSameDay(scheduleDate, day);
    }).map((schedule) => {
      ...schedule,
      'type': 'chore',
      'title': schedule['category']['name'] ?? '집안일',
      'assignee': schedule['assignedTo']['nickname'] ?? '담당자 없음',
      'categoryIcon': schedule['category']['icon'], // 아이콘 정보 추가
    });

    // 방문객 예약 필터링
    final visitorEvents = appState.visitorReservations.where((reservation) {
      if (reservation['specificDate'] == null) return false;
      final reservationDate = DateTime.parse(reservation['specificDate']);
      return isSameDay(reservationDate, day);
    }).map((reservation) => {
      ...reservation,
      'type': 'visitor',
      'title': '방문객',
      'assignee': reservation['reservedBy']['nickname'] ?? '예약자 없음',
      'categoryIcon': reservation['category']['icon'], // 아이콘 정보 추가
    });

    events.addAll(choreEvents);
    events.addAll(visitorEvents);

    return events;
  }

  // 이벤트 개수 표시용
  int _getEventCountForDay(DateTime day) {
    return _getEventsForDay(day).length;
  }

  // 카테고리별 아이콘 가져오기 (IconUtils 사용) - 추가
  IconData _getCategoryIcon(String categoryName, String? iconName, bool isChore) {
    // 저장된 아이콘 이름이 있으면 우선 사용
    if (iconName != null && iconName.isNotEmpty) {
      return IconUtils.getIconData(iconName);
    }

    // 카테고리 이름으로 기본 아이콘 반환
    return IconUtils.getDefaultIconForCategory(categoryName);
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final isChore = event['type'] == 'chore';
    final color = isChore ? Colors.redAccent : Colors.orangeAccent;
    final categoryName = event['title'];
    final categoryIcon = event['categoryIcon']; // 아이콘 정보 가져오기
    final icon = _getCategoryIcon(categoryName, categoryIcon, isChore);

    String subtitle = '';
    if (isChore) {
      subtitle = '담당자: ${event['assignee']}';
      if (event['isCompleted'] == true) {
        subtitle += ' (완료)';
      }
    } else {
      final startHour = event['startHour'] ?? 0;
      final endHour = event['endHour'] ?? 0;
      subtitle = '${event['assignee']} · $startHour:00-$endHour:00';

      final status = event['status'] ?? 'approved';
      if (status == 'pending') {
        subtitle += ' (승인 대기)';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20), // IconUtils로 가져온 아이콘 사용
        ),
        title: Text(
          event['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: (isChore && event['isCompleted'] == true)
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isChore && event['isCompleted'] == true
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0, // 캘린더가 첫 번째
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
        final appState = Provider.of<AppState>(context, listen: false);

        if (index == 0) {
          // 현재 캘린더 화면이므로 아무것도 하지 않음
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FullScheduleScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                roomName: appState.currentRoom?.roomName ?? '방',
                userName: appState.currentUser?.name ?? '사용자',
              ),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '캘린더',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 캘린더
              Container(
                color: Colors.white,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final eventCount = _getEventCountForDay(day);
                      if (eventCount > 0) {
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFA2E55),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$eventCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFFA2E55),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFFA2E55),
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.redAccent),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 선택된 날짜의 이벤트 목록
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // 날짜 헤더
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.2),
                          ),
                        ),
                        child: Text(
                          _selectedDay != null
                              ? _formatDate(_selectedDay!)
                              : '날짜를 선택하세요',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // 이벤트 목록
                      Expanded(
                        child: _selectedDay != null
                            ? () {
                          final events = _getEventsForDay(_selectedDay!);
                          if (events.isEmpty) {
                            return const Center(
                              child: Text(
                                '이 날에는 일정이 없습니다.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return _buildEventCard(events[index]);
                            },
                          );
                        }()
                            : const Center(
                          child: Text(
                            '날짜를 선택하면 일정을 확인할 수 있습니다.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
}