import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';

class BathScheduleScreen extends StatefulWidget {
  const BathScheduleScreen({super.key});

  @override
  State<BathScheduleScreen> createState() => _BathScheduleScreenState();
}

class _BathScheduleScreenState extends State<BathScheduleScreen> {
  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];

  String selectedDay = '월';
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool repeatWeekly = false;
  String? bathroomCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadReservationSchedules();

    // 욕실 카테고리 찾기
    final categories = appState.reservationCategories;
    final bathroomCategory = categories.firstWhere(
          (cat) => cat['name'] == '욕실',
      orElse: () => categories.isNotEmpty ? categories.first : {},
    );

    if (bathroomCategory.isNotEmpty) {
      bathroomCategoryId = bathroomCategory['_id'];
    }
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
    if (startTime == null || endTime == null || bathroomCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시간을 모두 선택해주세요.')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final dayOfWeek = days.indexOf(selectedDay);

    try {
      await appState.createReservationSchedule(
        categoryId: bathroomCategoryId!,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('욕실 예약이 등록되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약 등록 실패: $e')),
      );
    }
  }

  void _showReservationDialog(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('예약 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('예약자: ${reservation['reservedBy']['nickname']}'),
            Text('시간: ${reservation['startHour']}:00 ~ ${reservation['endHour']}:00'),
            Text('반복: ${reservation['isRecurring'] ? "매주" : "일회성"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              try {
                await appState.deleteReservationSchedule(reservation['_id']);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('예약이 삭제되었습니다.')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('삭제 실패: $e')),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: Color(0xFFFA2E55))),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // 욕실 예약만 필터링
        final bathroomReservations = appState.reservationSchedules
            .where((reservation) =>
        reservation['category'] != null &&
            reservation['category']['name'] == '욕실')
            .toList();

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
                            final day = days[dayIndex];
                            final matching = bathroomReservations.where((r) =>
                            r['dayOfWeek'] == dayIndex &&
                                r['startHour'] <= hour &&
                                r['endHour'] > hour);

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
                                    border:
                                    Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: matching.isNotEmpty
                                      ? Center(
                                    child: Text(
                                      matching.first['reservedBy']['nickname'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("욕실 예약")),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              Expanded(child: _buildSchedule()),
              const Divider(height: 1),
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 요일 선택
                    Row(
                      children: [
                        const Text("요일: "),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            String? result =
                            await showModalBottomSheet<String>(
                              context: context,
                              builder: (_) => ListView(
                                shrinkWrap: true,
                                children: days
                                    .map((d) => ListTile(
                                  title: Text(d),
                                  onTap: () =>
                                      Navigator.pop(context, d),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
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
                          child: Text(startTime == null
                              ? "--:--"
                              : startTime!.format(context)),
                        ),
                        const Text(" ~ "),
                        TextButton(
                          onPressed: () => _selectTime(false),
                          child: Text(endTime == null
                              ? "--:--"
                              : endTime!.format(context)),
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

                    // 등록 버튼
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFA2E55),
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