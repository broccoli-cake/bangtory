import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BathroomReserve extends StatefulWidget {
  const BathroomReserve({super.key});

  @override
  State<BathroomReserve> createState() => _BathroomReserveScreen();
}

class _BathroomReserveScreen extends State<BathroomReserve> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedPerson;
  List<String> members = ['김민영', '홍수한', '민수연', '최현정'];

  final List<Map<String, dynamic>> dutyList = [];

  void _addDuty() {
    if (selectedPerson != null) {
      setState(() {
        dutyList.add({
          'date': selectedDate,
          'person': selectedPerson,
          'checked': false,
        });
        selectedPerson = null;
      });
    }
  }

  void _deleteDuty(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                dutyList.removeAt(index);
              });
              Navigator.pop(context);
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
      appBar: AppBar(title: const Text('욕실 예약')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 등록된 일정 리스트
            Expanded(
              child: ListView.builder(
                itemCount: dutyList.length,
                itemBuilder: (context, index) {
                  final item = dutyList[index];
                  DateTime dt = item['date'];
                  String formattedDateTime =
                  DateFormat('yyyy-MM-dd HH:mm').format(dt);
                  return GestureDetector(
                    onLongPress: () => _deleteDuty(index),
                    child: ListTile(
                      title: Text("$formattedDateTime - ${item['person']}"),
                      trailing: Checkbox(
                        value: item['checked'],
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            dutyList[index]['checked'] = val!;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            // 날짜 선택
            Row(
              children: [
                const Text("날짜 선택: "),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          selectedDate.hour,
                          selectedDate.minute,
                        );
                      });
                    }
                  },
                  child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                ),
              ],
            ),
            // 시간 선택 버튼 (토마토 아이콘)
            Row(
              children: [
                const Text("시간 선택: "),
                IconButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.redAccent, // 토마토 빨강
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            timePickerTheme: const TimePickerThemeData(
                              dayPeriodColor: Colors.lightGreenAccent,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  },
                  icon: const Text(
                    '🍅',
                    style: TextStyle(fontSize: 28),
                  ),
                  tooltip: '시간 선택',
                ),
                const SizedBox(width: 8),
                Text(selectedTime.format(context)),
              ],
            ),
            // 당번 선택
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
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: _addDuty,
              child: const Text('등록하기'),
            ),
          ],
        ),
      ),
    );
  }
}
