import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/room_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android 에뮬레이터용
  // static const String baseUrl = 'http://localhost:3000'; // iOS 시뮬레이터용

  String? _userId;

  String? get userId => _userId;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_userId != null) 'X-User-ID': _userId!,
  };

  // ===== 사용자 관련 =====

  Future<UserModel> createUser({required String name}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}), // name 필드로 전송
      );

      print('Create User Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _userId = data['data']['id'];
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception('사용자 생성 실패: ${response.body}');
      }
    } catch (e) {
      print('Create User Error: $e');
      throw Exception('사용자 생성 중 오류 발생: $e');
    }
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<UserModel> getMyInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception('사용자 정보 조회 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('사용자 정보 조회 중 오류 발생: $e');
    }
  }

  // 사용자 프로필 정보 조회 (방 멤버 정보 포함)
  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me/profile'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProfileModel.fromJson(data['data']);
      } else {
        throw Exception('프로필 정보 조회 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('프로필 정보 조회 중 오류 발생: $e');
    }
  }

  // 사용자 프로필 수정
  Future<UserProfileModel> updateUserProfile({
    String? nickname,
    String? profileImageUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nickname != null) body['nickname'] = nickname;
      if (profileImageUrl != null) body['profileImageUrl'] = profileImageUrl;

      final response = await http.patch(
        Uri.parse('$baseUrl/users/me/profile'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProfileModel.fromJson(data['data']);
      } else {
        throw Exception('프로필 수정 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('프로필 수정 중 오류 발생: $e');
    }
  }

  // ===== 방 관련 =====

  Future<RoomModel> createRoom({
    required String roomName,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms'),
        headers: _headers,
        body: json.encode({
          'roomName': roomName,
          'address': address,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return RoomModel(
          roomId: data['room']['roomId'],
          roomName: data['room']['roomName'],
          address: data['room']['address'],
          isOwner: true,
          inviteCode: data['inviteCode'],
          expiresIn: data['expiresIn'],
        );
      } else {
        throw Exception('방 생성 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('방 생성 중 오류 발생: $e');
    }
  }

  Future<RoomModel> joinRoom(String inviteCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/join'),
        headers: _headers,
        body: json.encode({'inviteCode': inviteCode}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RoomModel(
          roomId: data['room']['roomId'],
          roomName: data['room']['roomName'],
          address: data['room']['address'],
          isOwner: false,
        );
      } else {
        throw Exception('방 참여 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('방 참여 중 오류 발생: $e');
    }
  }

  Future<RoomModel?> getMyRoom() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rooms/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RoomModel.fromJson(data['room']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('방 조회 실패: ${response.body}');
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> generateInviteCode(String roomId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/invite'),
        headers: _headers,
        body: json.encode({'roomId': roomId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['inviteCode'];
      } else {
        throw Exception('초대 코드 생성 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('초대 코드 생성 중 오류 발생: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rooms/$roomId/members'),
        headers: _headers,
      );

      print('Get Room Members Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['members']);
      } else {
        throw Exception('방 멤버 조회 실패: ${response.body}');
      }
    } catch (e) {
      print('Get Room Members Error: $e');
      throw Exception('방 멤버 조회 중 오류 발생: $e');
    }
  }

  // ===== 카테고리 관련 =====

  Future<List<Map<String, dynamic>>> getChoreCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chores'),
        headers: _headers,
      );

      print('Get Chore Categories Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('카테고리 조회 실패: ${response.body}');
      }
    } catch (e) {
      print('Get Chore Categories Error: $e');
      throw Exception('카테고리 조회 중 오류 발생: $e');
    }
  }

  Future<Map<String, dynamic>> createChoreCategory({
    required String name,
    required String icon,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chores'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'icon': icon,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('카테고리 생성 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('카테고리 생성 중 오류 발생: $e');
    }
  }

  Future<void> deleteChoreCategory(String categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chores/$categoryId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('카테고리 삭제 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('카테고리 삭제 중 오류 발생: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReservationCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/categories'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('예약 카테고리 조회 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('예약 카테고리 조회 중 오류 발생: $e');
    }
  }

  Future<Map<String, dynamic>> createReservationCategory({
    required String name,
    required String icon,
    bool requiresApproval = false,
    bool isVisitor = false,
  }) async {
    try {
      final body = {
        'name': name,
        'icon': icon,
        'requiresApproval': requiresApproval,
      };

      if (isVisitor) {
        body['isVisitor'] = true;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reservations/categories'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('예약 카테고리 생성 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('예약 카테고리 생성 중 오류 발생: $e');
    }
  }

  Future<void> deleteReservationCategory(String categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reservations/categories/$categoryId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('예약 카테고리 삭제 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('예약 카테고리 삭제 중 오류 발생: $e');
    }
  }

  // ===== 집안일 일정 관련 =====

  Future<List<Map<String, dynamic>>> getChoreSchedules({
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
    String? categoryId,
  }) async {
    try {
      final queryParams = {
        'roomId': roomId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (categoryId != null) 'categoryId': categoryId,
      };

      final uri = Uri.parse('$baseUrl/chores/schedules').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['schedules']);
      } else {
        throw Exception('일정 조회 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('일정 조회 중 오류 발생: $e');
    }
  }

  Future<Map<String, dynamic>> createChoreSchedule({
    required String roomId,
    required String categoryId,
    required String assignedTo,
    required DateTime date,
  }) async {
    try {
      final adjustedDate = DateTime(date.year, date.month, date.day, 12, 0, 0);

      final response = await http.post(
        Uri.parse('$baseUrl/chores/schedules'),
        headers: _headers,
        body: json.encode({
          'room': roomId,
          'category': categoryId,
          'assignedTo': assignedTo,
          'date': adjustedDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['schedule'];
      } else {
        throw Exception('일정 생성 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('일정 생성 중 오류 발생: $e');
    }
  }

  Future<Map<String, dynamic>> completeChoreSchedule(String scheduleId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/chores/schedules/$scheduleId/complete'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['schedule'];
      } else {
        throw Exception('일정 완료 처리 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('일정 완료 처리 중 오류 발생: $e');
    }
  }

  Future<void> deleteChoreSchedule(String scheduleId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chores/schedules/$scheduleId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('일정 삭제 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('일정 삭제 중 오류 발생: $e');
    }
  }

  // ===== 예약 일정 관련 =====

  Future<Map<String, dynamic>> createReservationSchedule({
    required String roomId,
    required String categoryId,
    int? dayOfWeek,
    DateTime? specificDate,
    required int startHour,
    required int endHour,
    bool isRecurring = false,
  }) async {
    try {
      final body = {
        'room': roomId,
        'category': categoryId,
        'startHour': startHour,
        'endHour': endHour,
      };

      if (specificDate != null) {
        // 방문객 예약: 날짜 부분만 추출해서 정오(12:00)로 설정
        // 이렇게 하면 시간대 변환되어도 같은 날짜가 유지됨
        final dateOnly = DateTime(
          specificDate.year,
          specificDate.month,
          specificDate.day,
          12, // 정오로 설정 (집안일과 동일한 방식)
          0,
          0,
        );

        body['specificDate'] = dateOnly.toIso8601String();
      } else if (dayOfWeek != null) {
        // 일반 예약: 요일 기반
        body['dayOfWeek'] = dayOfWeek;
        body['isRecurring'] = isRecurring;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reservations/schedules'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('예약 생성 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('예약 생성 중 오류 발생: $e');
    }
  }

  // 주간 예약 조회 - 경로 수정
  Future<List<Map<String, dynamic>>> getWeeklyReservations({
    required String roomId,
    DateTime? weekStartDate,
    String? categoryId,
  }) async {
    try {
      final queryParams = {
        if (weekStartDate != null) 'weekStartDate': weekStartDate.toIso8601String(),
        if (categoryId != null) 'categoryId': categoryId,
      };

      final uri = Uri.parse('$baseUrl/reservations/weekly-schedules/$roomId')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('예약 조회 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('예약 조회 중 오류 발생: $e');
    }
  }

  // 카테고리별 주간 예약 조회 - 경로 수정
  Future<List<Map<String, dynamic>>> getCategoryWeeklyReservations({
    required String roomId,
    required String categoryId,
  }) async {
    try {
      final url = '$baseUrl/reservations/category-schedules/$roomId/$categoryId';

      print('API 요청 URL: $url');
      print('Room ID: $roomId, Category ID: $categoryId');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('Get Category Weekly Reservations Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('카테고리별 예약 조회 실패: ${response.body}');
      }
    } catch (e) {
      print('Get Category Weekly Reservations Error: $e');
      throw Exception('카테고리별 예약 조회 중 오류 발생: $e');
    }
  }

  // 방문객 예약 조회 - 경로 수정
  Future<List<Map<String, dynamic>>> getVisitorReservations(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/visitor-schedules/$roomId'),
        headers: _headers,
      );

      print('Get Visitor Reservations Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('방문객 예약 조회 실패: ${response.body}');
      }
    } catch (e) {
      print('Get Visitor Reservations Error: $e');
      throw Exception('방문객 예약 조회 중 오류 발생: $e');
    }
  }

  // 대기 중인 예약 조회 - 경로 수정
  Future<List<Map<String, dynamic>>> getPendingReservations(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/pending-schedules/$roomId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('대기 중인 예약 조회 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('대기 중인 예약 조회 중 오류 발생: $e');
    }
  }

  Future<Map<String, dynamic>> approveReservation(String reservationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/reservations/schedules/$reservationId/approve'),
        headers: _headers,
      );

      print('Approve Reservation Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'isFullyApproved': data['data']['isFullyApproved'] ?? false,
          'currentApprovals': data['data']['currentApprovals'] ?? 0,
          'requiredApprovals': data['data']['requiredApprovals'] ?? 0,
          'remainingApprovals': data['data']['remainingApprovals'] ?? 0,
        };
      } else {
        throw Exception('예약 승인 실패: ${response.body}');
      }
    } catch (e) {
      print('Approve Reservation Error: $e');
      throw Exception('예약 승인 중 오류 발생: $e');
    }
  }

  Future<void> deleteReservationSchedule(String scheduleId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reservations/schedules/$scheduleId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('예약 삭제 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('예약 삭제 중 오류 발생: $e');
    }
  }
}