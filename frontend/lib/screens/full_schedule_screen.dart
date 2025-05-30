//예약 리스트는 임시 상태. 추후에 연동 예정

import 'package:flutter/material.dart';

class FullScheduleScreen extends StatefulWidget {
  const FullScheduleScreen({super.key});

  @override
  State<FullScheduleScreen> createState() => _FullScheduleScreenState();
}

class _FullScheduleScreenState extends State<FullScheduleScreen> {
  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];

  // 예시 예약 데이터 (욕실/세탁기 구분 포함)
  final List<Map<String, dynamic>> sampleReservations = [
    {
      'day': '월',
      'start': TimeOfDay(hour: 9, minute: 0),
      'end': TimeOfDay(hour: 10, minute: 0),
      'person': '김민영',
      'type': '욕실',
      'repeat': true,
    },
    {
      'day': '월',
      'start': TimeOfDay(hour: 9, minute: 0),
      'end': TimeOfDay(hour: 11, minute: 0),
      'person': '홍수한',
      'type': '세탁기',
      'repeat': false,
    },
    {
      'day': '화',
      'start': TimeOfDay(hour: 14, minute: 0),
      'end': TimeOfDay(hour: 15, minute: 30),
      'person': '민수연',
      'type': '욕실',
      'repeat': false,
    },
    {
      'day': '수',
      'start': TimeOfDay(hour: 18, minute: 0),
      'end': TimeOfDay(hour: 19, minute: 0),
      'person': '최현정',
      'type': '세탁기',
      'repeat': true,
    },
  ];

  void _showReservationDialog(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('예약 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('구분: ${reservation['type']}'),
            Text('예약자: ${reservation['person']}'),
            Text('시간: ${reservation['start'].format(context)} ~ ${reservation['end'].format(context)}'),
            Text('요일: ${reservation['day']}'),
            Text('매주 반복: ${reservation['repeat'] ? "예" : "아니오"}'),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('전체 예약 시간표')),
      body: Column(
        children: [
          // 요일 헤더
          Row(
            children: [
              const SizedBox(width: 50), // 시간표 왼쪽 여백
              ...days.map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                        SizedBox(
                          width: 50,
                          child: Text('$hour:00',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center),
                        ),
                        ...List.generate(7, (dayIndex) {
                          final day = days[dayIndex];

                          // 욕실 예약만 필터
                          final bathReservation = sampleReservations.where((r) =>
                          r['day'] == day &&
                              r['type'] == '욕실' &&
                              r['start'].hour <= hour &&
                              r['end'].hour > hour
                          ).toList();

                          // 세탁기 예약만 필터
                          final washerReservation = sampleReservations.where((r) =>
                          r['day'] == day &&
                              r['type'] == '세탁기' &&
                              r['start'].hour <= hour &&
                              r['end'].hour > hour
                          ).toList();

                          return Expanded(
                            child: Container(
                              height: 60,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  // 욕실 예약 영역 (좌측 절반)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: bathReservation.isNotEmpty
                                          ? () => _showReservationDialog(bathReservation.first)
                                          : null,
                                      child: Container(
                                        color: bathReservation.isNotEmpty
                                            ? Colors.redAccent.withOpacity(0.7)
                                            : Colors.grey[100],
                                        alignment: Alignment.center,
                                        child: bathReservation.isNotEmpty
                                            ? Text(
                                          bathReservation.first['person'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                            : null,
                                      ),
                                    ),
                                  ),

                                  // 세탁기 예약 영역 (우측 절반)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: washerReservation.isNotEmpty
                                          ? () => _showReservationDialog(washerReservation.first)
                                          : null,
                                      child: Container(
                                        color: washerReservation.isNotEmpty
                                            ? Colors.blueAccent.withOpacity(0.7)
                                            : Colors.grey[100],
                                        alignment: Alignment.center,
                                        child: washerReservation.isNotEmpty
                                            ? Text(
                                          washerReservation.first['person'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
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
      ),
    );
  }
}
