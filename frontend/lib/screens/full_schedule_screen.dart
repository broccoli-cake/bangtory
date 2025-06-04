import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/icon_utils.dart';
import '../settings/setting_home.dart';
import '../screens/home_screen.dart';
import '../screens/chat_screen.dart';
import '../settings/room/calendar.dart' as calendar_room;

class FullScheduleScreen extends StatefulWidget {
  const FullScheduleScreen({super.key});

  @override
  State<FullScheduleScreen> createState() => _FullScheduleScreenState();
}

class _FullScheduleScreenState extends State<FullScheduleScreen> {
  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];

  // 카테고리별 고정 색상 매핑
  final Map<String, Color> _categoryColorMap = {};
  final List<Color> _availableColors = [
    const Color(0xFF2E7D32),
    const Color(0xFF388E3C),
    const Color(0xFF4CAF50),
    const Color(0xFF66BB6A),
    const Color(0xFF8BC34A),
    const Color(0xFF9CCC65),
    const Color(0xFFAED581),
    const Color(0xFFCDDC39),
    const Color(0xFFD4E157),
    const Color(0xFFFFEB3B),
    const Color(0xFFFDD835),
    const Color(0xFFFFCA28),
    const Color(0xFFFFC107),
    const Color(0xFFFF9800),
    const Color(0xFFFF5722),
    const Color(0xFFFA2E55),
  ];

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

    // 카테고리별 색상 할당
    _assignCategoryColors(appState.reservationCategories);
  }

  // 카테고리별 색상 할당
  void _assignCategoryColors(List<Map<String, dynamic>> categories) {
    int colorIndex = 0;
    for (final category in categories) {
      if (category['isVisitor'] != true) {
        final categoryId = category['_id'];
        if (!_categoryColorMap.containsKey(categoryId)) {
          _categoryColorMap[categoryId] = _availableColors[colorIndex % _availableColors.length];
          colorIndex++;
        }
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

  // 카테고리별 색상 가져오기
  Color _getCategoryColor(String? categoryId) {
    if (categoryId == null) return Colors.grey;
    return _categoryColorMap[categoryId] ?? Colors.grey;
  }

  // 카테고리별 아이콘 매핑
  IconData _getCategoryIcon(String categoryName, String? iconName) {
    if (iconName != null && iconName.isNotEmpty) {
      return IconUtils.getIconData(iconName);
    }
    return IconUtils.getDefaultIconForCategory(categoryName);
  }

  // 특정 시간과 요일에 겹치는 예약들 찾기
  List<Map<String, dynamic>> _getOverlappingReservations(int hour, int dayIndex, List<Map<String, dynamic>> allReservations) {
    return allReservations.where((r) {
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
  }

  // 예약 정보 다이얼로그 표시
  void _showReservationDialog(Map<String, dynamic> reservation) {
    final category = reservation['category'];
    final reservedBy = reservation['reservedBy'];
    final categoryName = category?['name'] ?? '알 수 없음';
    final categoryIcon = category?['icon'];
    final nickname = reservedBy?['nickname'] ?? '알 수 없음';
    final startHour = reservation['startHour']?.toString() ?? '0';
    final endHour = reservation['endHour']?.toString() ?? '0';
    final isRecurring = reservation['isRecurring'] ?? false;
    final categoryColor = _getCategoryColor(category?['_id']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getCategoryIcon(categoryName, categoryIcon),
              color: categoryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('$categoryName 예약 정보')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('카테고리', categoryName, categoryColor),
            const SizedBox(height: 8),
            _buildInfoRow('예약자', nickname, Colors.grey[700]!),
            const SizedBox(height: 8),
            _buildInfoRow('시간', '$startHour:00 ~ $endHour:00', Colors.grey[700]!),
            const SizedBox(height: 8),
            _buildInfoRow('반복', isRecurring ? "매주" : "일회성", Colors.grey[700]!),
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

  // 겹치는 예약들 표시 다이얼로그
  void _showOverlappingReservationsDialog(List<Map<String, dynamic>> reservations, int hour, String dayName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$dayName요일 ${hour}:00 예약 목록'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              final category = reservation['category'];
              final reservedBy = reservation['reservedBy'];
              final categoryName = category?['name'] ?? '알 수 없음';
              final categoryIcon = category?['icon'];
              final nickname = reservedBy?['nickname'] ?? '알 수 없음';
              final startHour = reservation['startHour']?.toString() ?? '0';
              final endHour = reservation['endHour']?.toString() ?? '0';
              final categoryColor = _getCategoryColor(category?['_id']);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _getCategoryIcon(categoryName, categoryIcon),
                    color: categoryColor,
                  ),
                  title: Text(categoryName),
                  subtitle: Text('$nickname · $startHour:00-$endHour:00'),
                  trailing: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showReservationDialog(reservation);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color),
          ),
        ),
      ],
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: nonVisitorCategories.map((category) {
              final categoryName = category['name'] ?? '알 수 없음';
              final categoryIcon = category['icon'];
              final categoryId = category['_id'];
              final color = _getCategoryColor(categoryId);
              final icon = _getCategoryIcon(categoryName, categoryIcon);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 시간 슬롯 셀 빌드 (겹치는 예약 처리)
  Widget _buildTimeSlotCell(int hour, int dayIndex, List<Map<String, dynamic>> allReservations) {
    final overlappingReservations = _getOverlappingReservations(hour, dayIndex, allReservations);

    if (overlappingReservations.isEmpty) {
      return Container(
        height: 60,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    // 겹치는 예약이 1개인 경우
    if (overlappingReservations.length == 1) {
      final reservation = overlappingReservations.first;
      final category = reservation['category'];
      final reservedBy = reservation['reservedBy'];
      final categoryName = category?['name'] ?? '알 수 없음';
      final categoryIcon = category?['icon'];
      final categoryColor = _getCategoryColor(category?['_id']);

      return GestureDetector(
        onTap: () => _showReservationDialog(reservation),
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.7),
            border: Border.all(color: categoryColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(categoryName, categoryIcon),
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(height: 2),
              Text(
                reservedBy?['nickname']?.toString() ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    // 겹치는 예약이 여러 개인 경우 - 동적 분할
    return GestureDetector(
      onTap: () => _showOverlappingReservationsDialog(
        overlappingReservations,
        hour,
        days[dayIndex],
      ),
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: _buildOverlappingCell(overlappingReservations),
      ),
    );
  }

  // 겹치는 예약들을 가로로만 분할하여 표시
  Widget _buildOverlappingCell(List<Map<String, dynamic>> reservations) {
    final count = reservations.length;

    // 모든 경우에 가로 분할만 사용
    return Row(
      children: reservations.asMap().entries.map((entry) {
        final index = entry.key;
        final reservation = entry.value;
        final category = reservation['category'];
        final reservedBy = reservation['reservedBy'];
        final categoryColor = _getCategoryColor(category?['_id']);
        final categoryName = category?['name'] ?? '?';
        final nickname = reservedBy?['nickname'] ?? '';
        final categoryIcon = category?['icon'];

        return Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.7),
              border: index > 0 ? const Border(left: BorderSide(color: Colors.white, width: 1)) : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 아이콘 (공간이 충분한 경우)
                  if (count <= 3) ...[
                    Icon(
                      _getCategoryIcon(categoryName, categoryIcon),
                      color: Colors.white,
                      size: count <= 2 ? 16 : 12,
                    ),
                    const SizedBox(height: 2),
                  ],
                  // 카테고리 이름 (축약)
                  Text(
                    count <= 2 ? categoryName : categoryName.substring(0, 1),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: count <= 2 ? 9 : 8,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: count <= 2 ? 2 : 1,
                  ),
                  // 닉네임 (공간이 충분한 경우만)
                  if (count <= 2 && nickname.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      nickname.length > 3 ? '${nickname.substring(0, 3)}.' : nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
            MaterialPageRoute(builder: (_) => const calendar_room.CalendarScreen()),
          );
        } else if (index == 1) {
          // 현재 시간표 화면이므로 아무것도 하지 않음
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
                                      return Expanded(
                                        child: _buildTimeSlotCell(hour, dayIndex, allReservations),
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