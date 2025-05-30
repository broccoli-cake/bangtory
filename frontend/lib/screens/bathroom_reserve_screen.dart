import 'package:flutter/material.dart';

class BathScheduleScreen extends StatefulWidget {
  const BathScheduleScreen({super.key});

  @override
  State<BathScheduleScreen> createState() => _BathScheduleScreenState();
}

class _BathScheduleScreenState extends State<BathScheduleScreen> {
  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
  final List<String> members = ['김민영', '홍수한', '민수연', '최현정'];

  String selectedDay = '월';
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool repeatWeekly = false;
  String? selectedPerson;

  List<Map<String, dynamic>> reservations = [];

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

  void _addReservation() {
    if (startTime != null && endTime != null && selectedPerson != null) {
      reservations.add({
        'day': selectedDay,
        'start': startTime!,
        'end': endTime!,
        'person': selectedPerson!,
        'repeat': repeatWeekly,
      });
      setState(() {
        startTime = null;
        endTime = null;
        selectedPerson = null;
        repeatWeekly = false;
      });
    }
  }

  // 예약 셀 클릭 시 팝업
  void _showReservationDialog(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('예약 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('예약자: ${reservation['person']}'),
            Text(
                '시간: ${reservation['start'].format(context)} ~ ${reservation['end'].format(context)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                reservations.remove(reservation);
              });
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Color(0xFFFA2E55))),
          ),
        ],
      ),
    );
  }

  // 시간표 UI
  Widget _buildSchedule() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 30), // 시간표 왼쪽 여백
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
                        final matching = reservations.where((r) =>
                        r['day'] == day &&
                            r['start'].hour <= hour &&
                            r['end'].hour > hour);

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
                                  matching.first['person'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("욕실 예약")),
      body: Column(
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

                // 이름 선택
                Wrap(
                  spacing: 8.0,
                  children: members.map((name) {
                    final isSelected = selectedPerson == name;
                    return ChoiceChip(
                      label: Text(name),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedPerson = name;
                        });
                      },
                    );
                  }).toList(),
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
                    onPressed: _addReservation,
                    child: const Text("등록하기"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

