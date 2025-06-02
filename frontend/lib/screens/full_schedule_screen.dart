import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/icon_utils.dart'; // 추가
import '../settings/setting_home.dart';
import '../screens/home_screen.dart';
import '../screens/chat_screen.dart';
import '../settings/room/calendar.dart';

class FullScheduleScreen extends StatefulWidget {
  const FullScheduleScreen({super.key});

  @override
  State<FullScheduleScreen> createState() => _FullScheduleScreenState();
}

class _FullScheduleScreenState extends State<FullScheduleScreen> {
  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppState>(context, listen: false);

    // 예약 카테고리 로드
    await appState.loadReservationCategories();

    // 모든 예약 카테고리에 대해 현재 주 데이터 로드
    for (final category in appState.reservationCategories) {
      if (category['isVisitor'] != true) { // 방문객 카테고리 제외
        await appState.loadCategoryReservations(category['_id']);
      }
    }
  }

  // 모든 예약 데이터를 합쳐서 가져오기
  List<Map<String, dynamic>> _getAllReservations() {
    final appState = Provider.of<AppState>(context, listen: false);
    List<Map<String, dynamic>> allReservations = [];

    // 카테고리별로 저장된 예약 데이터를 모두 합치기
    for (final categoryId in appState.categoryReservations.keys) {
      final reservations = appState.categoryReservations[categoryId] ?? [];
      allReservations.addAll(reservations);
    }

    return allReservations;
  }

  // 카테고리별 색상 매핑
  Color _getCategoryColor(String categoryName) {
    final colorMap = {
      '욕실': Colors.redAccent,
      '세탁기': Colors.blueAccent,
      '주방': Colors.greenAccent,
      '거실': Colors.orangeAccent,
      '발코니': Colors.purpleAccent,
    };

    return colorMap[categoryName] ?? Colors.grey;
  }

  // 카테고리별 아이콘 매핑 (IconUtils 사용) - 수정
  IconData _getCategoryIcon(String categoryName, String? iconName) {
    // 저장된 아이콘 이름이 있으면 우선 사용
    if (iconName != null && iconName.isNotEmpty) {
      return IconUtils.getIconData(iconName);
    }

    // 카테고리 이름으로 기본 아이콘 반환
    return IconUtils.getDefaultIconForCategory(categoryName);
  }

  void _showReservationDialog(Map<String, dynamic> reservation) {
    final category = reservation['category'];
    final reservedBy = reservation['reservedBy'];
    final categoryName = category?['name'] ?? '알 수 없음';
    final categoryIcon = category?['icon']; // 아이콘 이름 가져오기
    final nickname = reservedBy?['nickname'] ?? '알 수 없음';
    final startHour = reservation['startHour']?.toString() ?? '0';
    final endHour = reservation['endHour']?.toString() ?? '0';
    final isRecurring = reservation['isRecurring'] ?? false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$categoryName 예약 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(categoryName, categoryIcon),
                  color: _getCategoryColor(categoryName),
                ),
                const SizedBox(width: 8),
                Text('카테고리: $categoryName'),
              ],
            ),
            const SizedBox(height: 8),
            Text('예약자: $nickname'),
            Text('시간: $startHour:00 ~ $endHour:00'),
            Text('반복: ${isRecurring ? "매주" : "일회성"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend() {
    final appState = Provider.of<AppState>(context, listen: false);
    final nonVisitorCategories = appState.reservationCategories
        .where((category) => category['isVisitor'] != true)
        .toList();

    if (nonVisitorCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 1),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: nonVisitorCategories.map((category) {
              final categoryName = category['name'] ?? '알 수 없음';
              final categoryIcon = category['icon']; // 아이콘 이름 가져오기
              final color = _getCategoryColor(categoryName);
              final icon = _getCategoryIcon(categoryName, categoryIcon);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(categoryName, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, // 시간표가 두 번째
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CalendarScreen()),
          );
        } else if (index == 1) {
          // 현재 시간표 화면이므로 아무것도 하지 않음
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                roomName: appState.currentRoom?.roomName ?? '방',
                userName: appState.currentUser?.nickname ?? '사용자',
              ),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '전체 예약 시간표',
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

          final allReservations = _getAllReservations();

          return Column(
            children: [
              // 카테고리 범례
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCategoryLegend(),
              ),

              // 시간표
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // 요일 헤더
                      Row(
                        children: [
                          const SizedBox(width: 50), // 시간 컬럼 공간
                          ...days.map((d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )).toList(),
                        ],
                      ),
                      const Divider(height: 1),

                      // 시간표 본문
                      Expanded(
                        child: ListView.builder(
                          itemCount: 24,
                          itemBuilder: (_, hour) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // 시간 표시
                                    SizedBox(
                                      width: 50,
                                      child: Text(
                                        '$hour:00',
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    // 각 요일별 셀
                                    ...List.generate(7, (dayIndex) {
                                      // 해당 시간과 요일에 맞는 예약들 찾기
                                      final matchingReservations = allReservations.where((r) {
                                        final dayOfWeek = r['dayOfWeek'];
                                        final startHour = r['startHour'];
                                        final endHour = r['endHour'];

                                        if (dayOfWeek == null || startHour == null || endHour == null) {
                                          return false;
                                        }

                                        int? dayOfWeekInt;
                                        int? startHourInt;
                                        int? endHourInt;

                                        // 안전한 int 변환
                                        if (dayOfWeek is int) {
                                          dayOfWeekInt = dayOfWeek;
                                        } else if (dayOfWeek is String) {
                                          dayOfWeekInt = int.tryParse(dayOfWeek);
                                        }

                                        if (startHour is int) {
                                          startHourInt = startHour;
                                        } else if (startHour is String) {
                                          startHourInt = int.tryParse(startHour);
                                        }

                                        if (endHour is int) {
                                          endHourInt = endHour;
                                        } else if (endHour is String) {
                                          endHourInt = int.tryParse(endHour);
                                        }

                                        return dayOfWeekInt == dayIndex &&
                                            startHourInt != null && startHourInt <= hour &&
                                            endHourInt != null && endHourInt > hour;
                                      }).toList();

                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: matchingReservations.isNotEmpty
                                              ? () => _showReservationDialog(matchingReservations.first)
                                              : null,
                                          child: Container(
                                            height: 60,
                                            margin: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: matchingReservations.isNotEmpty
                                                  ? () {
                                                final category = matchingReservations.first['category'];
                                                final categoryName = category?['name'] ?? '알 수 없음';
                                                return _getCategoryColor(categoryName).withOpacity(0.7);
                                              }()
                                                  : Colors.grey[100],
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: matchingReservations.isNotEmpty
                                                ? Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  _getCategoryIcon(
                                                    matchingReservations.first['category']?['name'] ?? '알 수 없음',
                                                    matchingReservations.first['category']?['icon'], // 아이콘 이름 추가
                                                  ),
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  matchingReservations.first['reservedBy']?['nickname']?.toString() ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            )
                                                : null,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            );
                          },
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