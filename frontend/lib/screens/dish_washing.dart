// cleaning_duty_screen.dart

import 'package:flutter/material.dart';

class dishwashing extends StatefulWidget {
  const dishwashing({super.key});

  @override
  State<dishwashing> createState() => _CleaningDutyScreenState();
}

class _CleaningDutyScreenState extends State<dishwashing> {
  DateTime selectedDate = DateTime.now();
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
      appBar: AppBar(title: const Text('설거지 당번')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 등록 일정
            Expanded(
              child: ListView.builder(
                itemCount: dutyList.length,
                itemBuilder: (context, index) {
                  final item = dutyList[index];
                  return GestureDetector(
                    onLongPress: () => _deleteDuty(index),
                    child: ListTile(
                      title: Text(
                        "${item['date'].toString().split(' ')[0]} - ${item['person']}",
                      ),
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
