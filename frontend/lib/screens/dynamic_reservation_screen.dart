import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/dialog_utils.dart';

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
  int? startHour;
  int? endHour;
  bool repeatWeekly = false;

  // 방문객 예약용
  DateTime selectedDate = DateTime.now();
  int? visitorStartHour;
  int? visitorEndHour;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 날짜 포맷팅 함수 추가
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppState>(context, listen: false);

    if (isVisitorCategory) {
      // 방문객 예약인 경우 별도 메서드 호출
      await appState.loadVisitorReservations();
    } else {
      // 일반 예약인 경우 카테고리별 데이터 로드
      await appState.loadCategoryReservations(widget.category['_id']);
    }
  }

  // 시간 드롭다운 빌더
  Widget _buildHourDropdown({
    required String label,
    required int? selectedValue,
    required ValueChanged<int?> onChanged,
    int startRange = 0,
    int endRange = 23,
  }) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: selectedValue,
          hint: const Text('선택'),
          items: List.generate(endRange - startRange + 1, (index) {
            final hour = startRange + index;
            return DropdownMenuItem<int>(
              value: hour,
              child: Text('${hour.toString().padLeft(2, '0')}:00'),
            );
          }),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _addReservation() async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      if (isVisitorCategory) {
        // 방문객 예약 - 시작/종료 시간 검증
        if (visitorStartHour == null || visitorEndHour == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시작 시간과 종료 시간을 모두 선택해주세요.')),
          );
          return;
        }

        if (visitorStartHour! >= visitorEndHour!) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시작 시간은 종료 시간보다 빨라야 합니다.')),
          );
          return;
        }

        // 방문객 예약 - 날짜 정확히 조합
        final reservationDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );

        await appState.createReservationSchedule(
          categoryId: widget.category['_id'],
          specificDate: reservationDate,
          startHour: visitorStartHour!,
          endHour: visitorEndHour!,
        );

        // 성공 후 필드 초기화
        setState(() {
          visitorStartHour = null;
          visitorEndHour = null;
        });
      } else {
        // 일반 예약 - 시작/종료 시간 검증
        if (startHour == null || endHour == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시작 시간과 종료 시간을 모두 선택해주세요.')),
          );
          return;
        }

        if (startHour! >= endHour!) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시작 시간은 종료 시간보다 빨라야 합니다.')),
          );
          return;
        }

        final dayOfWeek = days.indexOf(selectedDay);

        await appState.createReservationSchedule(
          categoryId: widget.category['_id'],
          dayOfWeek: dayOfWeek,
          startHour: startHour!,
          endHour: endHour!,
          isRecurring: repeatWeekly,
        );

        // 성공 후 필드 초기화
        setState(() {
          startHour = null;
          endHour = null;
          repeatWeekly = false;
        });
      }

      // 예약 등록 성공 후 알림 개수 업데이트
      await appState.loadUnreadNotificationCount();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.category['name']} 예약이 등록되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('예약 등록 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteReservation(Map<String, dynamic> reservation) async {
    final shouldDelete = await DialogUtils.showDeleteConfirmDialog(
      context,
      title: '예약 삭제',
      content: '${widget.category['name']} 예약을 삭제하시겠습니까?',
    );

    if (shouldDelete) {
      final appState = Provider.of<AppState>(context, listen: false);
      try {
        await appState.deleteReservationSchedule(reservation['_id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('예약이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _approveReservation(Map<String, dynamic> reservation) async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      final result = await appState.approveReservation(reservation['_id']);

      // 성공 후 알림 개수 업데이트
      await appState.loadUnreadNotificationCount();

      final remainingApprovals = result['remainingApprovals'] ?? 0;

      if (remainingApprovals > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('승인했습니다. ${remainingApprovals}명의 승인이 더 필요합니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 멤버가 승인했습니다! 예약이 최종 승인되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('승인 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // 승인자 목록 위젯
  Widget _buildApprovalList(List approvedBy) {
    if (approvedBy.isEmpty) {
      return const SizedBox.shrink();
    }

    final approverNames = approvedBy
        .map((app) => app['user']['nickname']?.toString() ?? '알 수 없음')
        .join(', ');

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '승인한 멤버: $approverNames',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.blue,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // 상태에 따른 부제목 색상
  Color _getSubtitleColor(String status, String approvalStatus) {
    if (status == 'pending') {
      switch (approvalStatus) {
        case 'pending':
          return Colors.red;
        case 'partial_approved':
          return Colors.orange;
        case 'fully_approved':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    } else if (status == 'approved') {
      return Colors.green;
    }
    return Colors.grey;
  }

  Widget _buildVisitorReservationList() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // 방문객 예약 목록 사용
        final reservations = appState.visitorReservations.where((reservation) {
          if (reservation['category'] == null) return false;

          final reservationCategory = reservation['category'];
          if (reservationCategory is Map<String, dynamic>) {
            final reservationCategoryId = reservationCategory['_id']?.toString();
            final targetCategoryId = widget.category['_id']?.toString();
            return reservationCategoryId == targetCategoryId;
          }
          return false;
        }).toList();

        if (reservations.isEmpty) {
          return const Center(
            child: Text(
              '등록된 방문객 예약이 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

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
            final status = reservation['status'] ?? 'approved';
            final approvalStatus = reservation['approvalStatus'] ?? 'approved';
            final startHour = reservation['startHour'] ?? 0;
            final endHour = reservation['endHour'] ?? 0;

            // 승인 정보
            final currentApprovals = reservation['currentApprovals'] ?? 0;
            final requiredApprovals = reservation['requiredApprovals'] ?? 0;
            final totalMembers = reservation['totalMembers'] ?? 0;

            // 현재 사용자가 이미 승인했는지 확인
            bool hasUserApproved = false;
            final approval = reservation['approval'];
            if (approval != null && approval['approvedBy'] != null) {
              final approvedBy = approval['approvedBy'] as List;
              hasUserApproved = approvedBy.any((app) =>
              app['user']['_id']?.toString() == appState.apiService.userId
              );
            }

            // 상태에 따른 색상 및 텍스트 설정
            Color cardColor = Colors.white;
            Color borderColor = Colors.grey.shade300;
            String statusText = '';
            String subtitleText = '';

            if (status == 'pending') {
              if (approvalStatus == 'pending') {
                cardColor = Colors.red.shade50;
                borderColor = Colors.red.shade300;
                statusText = ' (승인 대기 - $currentApprovals/$requiredApprovals)';
                subtitleText = '모든 방 멤버의 승인이 필요합니다';
              } else if (approvalStatus == 'partial_approved') {
                cardColor = Colors.orange.shade50;
                borderColor = Colors.orange.shade300;
                statusText = ' (부분 승인 - $currentApprovals/$requiredApprovals)';
                subtitleText = '${requiredApprovals - currentApprovals}명의 승인이 더 필요합니다';
              } else if (approvalStatus == 'fully_approved') {
                cardColor = Colors.blue.shade50;
                borderColor = Colors.blue.shade300;
                statusText = ' (승인 완료 처리 중...)';
                subtitleText = '모든 멤버가 승인했습니다. 곧 최종 승인됩니다.';
              }
            } else if (status == 'approved') {
              cardColor = Colors.green.shade50;
              borderColor = Colors.green.shade300;
              statusText = ' (최종 승인)';
              subtitleText = '예약이 확정되었습니다';
            }

            return Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: borderColor, width: 1),
              ),
              child: ListTile(
                title: Text("${_formatDate(specificDate)} ${startHour.toString().padLeft(2, '0')}:00-${endHour.toString().padLeft(2, '0')}:00 - $nickname$statusText",
                  style: TextStyle(
                    fontWeight: status == 'pending' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitleText,
                      style: TextStyle(
                        color: _getSubtitleColor(status, approvalStatus),
                        fontSize: 12,
                      ),
                    ),
                    // 승인자 목록 표시 (대기 중인 예약만)
                    if (status == 'pending' && approval != null && approval['approvedBy'] != null)
                      _buildApprovalList(approval['approvedBy']),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 승인 버튼 (조건: 대기 중, 본인 예약 아님, 아직 승인 안함)
                    if (status == 'pending' &&
                        reservedBy['_id']?.toString() != appState.apiService.userId &&
                        !hasUserApproved)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                        onPressed: () => _approveReservation(reservation),
                        tooltip: '승인',
                      ),
                    // 이미 승인한 경우 체크 표시
                    if (status == 'pending' && hasUserApproved)
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    // 삭제 버튼
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReservation(reservation),
                    ),
                  ],
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
        // 해당 카테고리의 예약 데이터만 가져오기
        final reservations = appState.getCategoryReservations(widget.category['_id']);

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
            Text('시간: ${startHour.padLeft(2, '0')}:00 ~ ${endHour.padLeft(2, '0')}:00'),
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
              child: Text(_formatDate(selectedDate)),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 시작 시간 선택
        _buildHourDropdown(
          label: "시작 시간: ",
          selectedValue: visitorStartHour,
          onChanged: (value) {
            setState(() {
              visitorStartHour = value;
            });
          },
        ),

        const SizedBox(height: 8),

        // 종료 시간 선택
        _buildHourDropdown(
          label: "종료 시간: ",
          selectedValue: visitorEndHour,
          onChanged: (value) {
            setState(() {
              visitorEndHour = value;
            });
          },
          startRange: 1,
          endRange: 24,
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

        // 시작 시간 선택
        _buildHourDropdown(
          label: "시작 시간: ",
          selectedValue: startHour,
          onChanged: (value) {
            setState(() {
              startHour = value;
            });
          },
        ),

        const SizedBox(height: 8),

        // 종료 시간 선택
        _buildHourDropdown(
          label: "종료 시간: ",
          selectedValue: endHour,
          onChanged: (value) {
            setState(() {
              endHour = value;
            });
          },
          startRange: 1,
          endRange: 24,
        ),

        const SizedBox(height: 8),

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
                          backgroundColor: const Color(0xFFFA2E55),
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