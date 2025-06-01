import 'package:flutter/material.dart';

class TrashDutyScreen extends StatefulWidget {
  const TrashDutyScreen({super.key});

  @override
  State<TrashDutyScreen> createState() => _TrashDutyState();
}

class _TrashDutyState extends State<TrashDutyScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedPerson;
  List<String> members = ['김민영', '홍수한', '민수연', '최현정'];

  void _addDuty() {
    if (selectedPerson != null) {
      // 등록 버튼 누르면 현재 선택된 날짜와 당번 정보만 넘기고 화면 종료
      Navigator.pop(context, {
        'date': selectedDate,
        'person': selectedPerson,
        'done': false, // 필드명 done으로 통일
      });
    } else {
      // 당번 미선택 시 간단 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('당번을 선택해주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('분리수거 당번 등록')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text("${selectedDate.toLocal()}".split(' ')[0]),
                ),
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
