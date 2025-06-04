import 'package:flutter/material.dart';

class CleaningDutyScreen extends StatefulWidget {
const CleaningDutyScreen({super.key});

@override
State<CleaningDutyScreen> createState() => _CleaningDutyScreenState();
}

class _CleaningDutyScreenState extends State<CleaningDutyScreen> {
DateTime selectedDate = DateTime.now();
String? selectedPerson;
List<String> members = ['김민영', '홍수한', '민수연', '최현정'];

void _addDuty() {
if (selectedPerson != null) {
Navigator.pop(context, {
'date': selectedDate,
'person': selectedPerson,
});
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('당번을 선택해주세요')),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('청소 당번')),
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
