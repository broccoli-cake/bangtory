import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_state.dart';

class VisitReserve extends StatefulWidget {
  const VisitReserve({super.key});

  @override
  State<VisitReserve> createState() => _VisitReserveState();
}

class _VisitReserveState extends State<VisitReserve> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? visitorCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadReservationSchedules();

    // 방문객 카테고리 찾기
    final categories = appState.reservationCategories;
    final visitorCategory = categories.firstWhere(
          (cat) => cat['name'] == '방문객',
      orElse: () => categories.isNotEmpty ? categories.first : {},
    );

    if (visitorCategory.isNotEmpty) {
      visitorCategoryId = visitorCategory['_id'];
    }
  }

  Future<void> _addReservation() async {
    if (visitorCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방문객 카테고리를 찾을 수 없습니다.')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    // 선택된 날짜와 시간을 합치기
    final reservationDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    try {
      await appState.createReservationSchedule(
        categoryId: visitorCategoryId!,
        specificDate: reservationDateTime,
        startHour: selectedTime.hour,
        endHour: selectedTime.hour + 1, // 1시간 예약
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방문객 예약이 등록되었습니다.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('방문객 예약')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // 방문객 예약만 필터링
          final visitorReservations = appState.reservationSchedules
              .where((reservation) =>
          reservation['category'] != null &&
              reservation['category']['name'] == '방문객')
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 등록된 일정 리스트
                Expanded(
                  child: ListView.builder(
                    itemCount: visitorReservations.length,
                    itemBuilder: (context, index) {
                      final reservation = visitorReservations[index];
                      final specificDate = DateTime.parse(reservation['specificDate']);
                      final reservedBy = reservation['reservedBy'];

                      return Card(
                        child: ListTile(
                          title: Text(
                            "${DateFormat('yyyy-MM-dd HH:mm').format(specificDate)} - ${reservedBy['nickname']}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReservation(reservation),
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
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.redAccent,
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

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: appState.isLoading ? null : _addReservation,
                    child: appState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('등록하기'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}