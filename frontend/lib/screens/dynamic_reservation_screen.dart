import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_state.dart';

class DynamicReservationScreen extends StatefulWidget {
  final Map<String, dynamic> category;

  const DynamicReservationScreen({
    super.key,
    required this.category,
  });

  @override
  State<DynamicReservationScreen> createState() => _DynamicReservationScreenState();
}

class _DynamicReservationScreenState extends State<DynamicReservationScreen> {
  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];

  // 방문객 카테고리 여부 확인
  bool get isVisitorCategory => widget.category['isVisitor'] == true;

  // 일반 예약용
  String selectedDay = '월';
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool repeatWeekly = false;

  // 방문객 예약용
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadReservationSchedules();
  }

  void _selectTime(bool isStart) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _addReservation() async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      if (isVisitorCategory) {
        // 방문객 예약
        final reservationDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        await appState.createReservationSchedule(
          categoryId: widget.category['_id'],
          specificDate: reservationDateTime,
          startHour: selectedTime.hour,
          endHour: selectedTime.hour + 1,
        );
      } else {
        // 일반 예약
        if (startTime == null || endTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시간을 모두 선택해주세요.')),
          );
          return;
        }

        final dayOfWeek = days.indexOf(selectedDay);

        await appState.createReservationSchedule(
          categoryId: widget.category['_id'],
          dayOfWeek: dayOfWeek,
          startHour: startTime!.hour,
          endHour: endTime!.hour,
          isRecurring: repeatWeekly,
        );

        setState(() {
          startTime = null;
          endTime = null;
          repeatWeekly = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.category['name']} 예약이 등록되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약 등록 실패: $e')),
      );
    }
  }

  Future<void> _deleteReservation(Map<String, dynamic> reservation) async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.deleteReservationSchedule(reservation['_id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 삭제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
    }
  }

  Widget _buildVisitorReservationList() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // 안전한 필터링
        final reservations = appState.reservationSchedules.where((reservation) {
          if (reservation['category'] == null) return false;

          final reservationCategory = reservation['category'];
          if (reservationCategory is Map<String, dynamic>) {
            final reservationCategoryId = reservationCategory['_id']?.toString();
            final targetCategoryId = widget.category['_id']?.toString();
            return reservationCategoryId == targetCategoryId;
          }
          return false;
        }).toList();

        return ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];

            // 안전한 데이터 접근
            final specificDateStr = reservation['specificDate']?.toString();
            if (specificDateStr == null) return const SizedBox.shrink();

            final specificDate = DateTime.tryParse(specificDateStr);
            if (specificDate == null) return const SizedBox.shrink();

            final reservedBy = reservation['reservedBy'];
            if (reservedBy == null) return const SizedBox.shrink();

            final nickname = reservedBy['nickname']?.toString() ?? '알 수 없음';

            return Card(
              child: ListTile(
                title: Text(
                  "${DateFormat('yyyy-MM-dd HH:mm').format(specificDate)} - $nickname",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteReservation(reservation),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRegularReservationSchedule() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // 안전한 필터링
        final reservations = appState.reservationSchedules.where((reservation) {
          if (reservation['category'] == null) return false;

          final reservationCategory = reservation['category'];
          if (reservationCategory is Map<String, dynamic>) {
            final reservationCategoryId = reservationCategory['_id']?.toString();
            final targetCategoryId = widget.category['_id']?.toString();
            return reservationCategoryId == targetCategoryId;
          }
          return false;
        }).toList();

        return Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 30),
                ...days.map(
                      (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: 24,
                itemBuilder: (_, hour) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text('$hour',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center),
                          ),
                          ...List.generate(7, (dayIndex) {
                            // 안전한 필터링
                            final matching = reservations.where((r) {
                              final dayOfWeek = r['dayOfWeek'];
                              final startHour = r['startHour'];
                              final endHour = r['endHour'];

                              // null 체크 및 타입 변환
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
                                onTap: matching.isNotEmpty
                                    ? () => _showReservationDialog(matching.first)
                                    : null,
                                child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: matching.isNotEmpty
                                        ? Colors.redAccent.withOpacity(0.5)
                                        : Colors.grey[100],
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: matching.isNotEmpty
                                      ? Center(
                                    child: Text(
                                      matching.first['reservedBy']?['nickname']?.toString() ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ),
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
        );
      },
    );
  }

  void _showReservationDialog(Map<String, dynamic> reservation) {
    final reservedBy = reservation['reservedBy'];
    final nickname = reservedBy?['nickname']?.toString() ?? '알 수 없음';
    final startHour = reservation['startHour']?.toString() ?? '0';
    final endHour = reservation['endHour']?.toString() ?? '0';
    final isRecurring = reservation['isRecurring'] ?? false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('예약 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('예약자: $nickname'),
            Text('시간: $startHour:00 ~ $endHour:00'),
            Text('반복: ${isRecurring ? "매주" : "일회성"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteReservation(reservation);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Color(0xFFFA2E55))),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorInputForm() {
    return Column(
      children: [
        // 날짜 선택
        Row(
          children: [
            const Text("날짜 선택: "),
            TextButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
            ),
          ],
        ),

        // 시간 선택
        Row(
          children: [
            const Text("시간 선택: "),
            IconButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              icon: const Text('🍅', style: TextStyle(fontSize: 28)),
              tooltip: '시간 선택',
            ),
            const SizedBox(width: 8),
            Text(selectedTime.format(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildRegularInputForm() {
    return Column(
      children: [
        // 요일 선택
        Row(
          children: [
            const Text("요일: "),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                String? result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (_) => ListView(
                    shrinkWrap: true,
                    children: days
                        .map((d) => ListTile(
                      title: Text(d),
                      onTap: () => Navigator.pop(context, d),
                    ))
                        .toList(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    selectedDay = result;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFFA2E55)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(selectedDay),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),

        // 시간 선택
        Row(
          children: [
            const Text("시간: "),
            TextButton(
              onPressed: () => _selectTime(true),
              child: Text(startTime == null ? "--:--" : startTime!.format(context)),
            ),
            const Text(" ~ "),
            TextButton(
              onPressed: () => _selectTime(false),
              child: Text(endTime == null ? "--:--" : endTime!.format(context)),
            ),
          ],
        ),

        // 반복 버튼
        Row(
          children: [
            const Text("매주 반복: "),
            Switch(
              value: repeatWeekly,
              onChanged: (val) {
                setState(() {
                  repeatWeekly = val;
                });
              },
              activeColor: Color(0xFFFA2E55),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.category['name']} 예약")),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              // 예약 목록 표시
              Expanded(
                child: isVisitorCategory
                    ? _buildVisitorReservationList()
                    : _buildRegularReservationSchedule(),
              ),
              const Divider(height: 1),

              // 입력 폼
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isVisitorCategory
                        ? _buildVisitorInputForm()
                        : _buildRegularInputForm(),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: appState.isLoading ? null : _addReservation,
                        child: appState.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("등록하기"),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}