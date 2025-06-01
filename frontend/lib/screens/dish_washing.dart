
import 'package:flutter/material.dart';

class Dishwashing extends StatefulWidget {
const Dishwashing({super.key});

@override
State<Dishwashing> createState() => _DishwashingState();
}

class _DishwashingState extends State<Dishwashing> {
DateTime selectedDate = DateTime.now();
String? selectedPerson;
List<String> members = ['김민영', '홍수한', '민수연', '최현정'];
final List<Map<String, dynamic>> dutyList = [];

void _addDuty() {
if (selectedPerson != null) {
// 등록된 당번과 날짜를 Map 형태로 넘겨서 pop
Navigator.pop(context, {
'date': selectedDate,
'person': selectedPerson,
});
} else {
// 선택 안 한 경우 간단한 안내 메시지
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('당번을 선택해주세요')),
);
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
appBar: AppBar(title: const Text('설거지 당번 등록')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
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
