import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  UserProfileModel? _currentUserProfile;
  RoomModel? _currentRoom;
  bool _isLoading = false;
  List<Map<String, dynamic>> _choreCategories = [];
  List<Map<String, dynamic>> _reservationCategories = [];
  List<Map<String, dynamic>> _choreSchedules = [];
  List<Map<String, dynamic>> _reservationSchedules = [];
  List<Map<String, dynamic>> _roomMembers = [];
  List<Map<String, dynamic>> _visitorReservations = [];
  List<Map<String, dynamic>> _pendingReservations = [];
  Map<String, List<Map<String, dynamic>>> _categoryReservations = {};

  UserModel? get currentUser => _currentUser;
  UserProfileModel? get currentUserProfile => _currentUserProfile;
  RoomModel? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  ApiService get apiService => _apiService;
  List<Map<String, dynamic>> get choreCategories => _choreCategories;
  List<Map<String, dynamic>> get reservationCategories => _reservationCategories;
  List<Map<String, dynamic>> get choreSchedules => _choreSchedules;
  List<Map<String, dynamic>> get reservationSchedules => _reservationSchedules;
  List<Map<String, dynamic>> get roomMembers => _roomMembers;
  List<Map<String, dynamic>> get visitorReservations => _visitorReservations;
  List<Map<String, dynamic>> get pendingReservations => _pendingReservations;
  Map<String, List<Map<String, dynamic>>> get categoryReservations => _categoryReservations;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ===== 사용자 관련 =====

  Future<void> createUser({required String name}) async {
    setLoading(true);
    try {
      _currentUser = await _apiService.createUser(name: name);
      await _saveUserId(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      print('Create user error: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadUser() async {
    final userId = await _getUserId();
    if (userId != null) {
      setLoading(true);
      try {
        _apiService.setUserId(userId);
        _currentUser = await _apiService.getMyInfo();
        await loadRoom();
        notifyListeners();
      } catch (e) {
        print('Load user error: $e');
        await _clearUserId();
      } finally {
        setLoading(false);
      }
    }
  }

  // 사용자 프로필 정보 로드
  Future<void> loadUserProfile() async {
    try {
      _currentUserProfile = await _apiService.getUserProfile();
      notifyListeners();
    } catch (e) {
      print('Load user profile error: $e');
    }
  }

  // 사용자 프로필 수정
  Future<void> updateUserProfile({
    String? nickname,
    String? profileImageUrl,
  }) async {
    setLoading(true);
    try {
      _currentUserProfile = await _apiService.updateUserProfile(
        nickname: nickname,
        profileImageUrl: profileImageUrl,
      );

      // 방 멤버 목록도 다시 로드하여 업데이트된 정보 반영
      await loadRoomMembers();

      notifyListeners();
    } catch (e) {
      print('Update user profile error: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // ===== 방 관련 =====

  Future<void> createRoom({
    required String roomName,
    String? address,
  }) async {
    setLoading(true);
    try {
      _currentRoom = await _apiService.createRoom(
        roomName: roomName,
        address: address,
      );
      await loadRoomMembers();
      // 방 생성 후 프로필 정보도 로드 (닉네임, 프로필 이미지가 자동 생성됨)
      await loadUserProfile();
      notifyListeners();
    } catch (e) {
      print('Create room error: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> joinRoom(String inviteCode) async {
    setLoading(true);
    try {
      _currentRoom = await _apiService.joinRoom(inviteCode);
      await loadRoomMembers();
      // 방 참여 후 프로필 정보도 로드 (닉네임, 프로필 이미지가 자동 생성됨)
      await loadUserProfile();
      notifyListeners();
    } catch (e) {
      print('Join room error: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadRoom() async {
    try {
      _currentRoom = await _apiService.getMyRoom();
      if (_currentRoom != null) {
        await loadRoomMembers();
        await loadUserProfile();
      }
      notifyListeners();
    } catch (e) {
      print('Load room error: $e');
    }
  }

  Future<String> generateInviteCode() async {
    if (_currentRoom == null) {
      throw Exception('참여 중인 방이 없습니다.');
    }

    try {
      return await _apiService.generateInviteCode(_currentRoom!.roomId);
    } catch (e) {
      print('Generate invite code error: $e');
      rethrow;
    }
  }

  Future<void> loadRoomMembers() async {
    if (_currentRoom == null) return;

    try {
      _roomMembers = await _apiService.getRoomMembers(_currentRoom!.roomId);
      notifyListeners();
    } catch (e) {
      print('Load room members error: $e');
    }
  }

  // ===== 카테고리 관련 =====

  Future<void> loadChoreCategories() async {
    try {
      final categories = await _apiService.getChoreCategories();

      // 생성 순서대로 정렬 (기본 카테고리 먼저, 그 다음 생성시간 순)
      categories.sort((a, b) {
        // 기본 카테고리를 먼저 표시
        final aType = a['type']?.toString() ?? 'custom';
        final bType = b['type']?.toString() ?? 'custom';

        if (aType == 'default' && bType != 'default') return -1;
        if (bType == 'default' && aType != 'default') return 1;

        // 같은 타입이면 생성시간 순 (createdAt 기준)
        final aCreatedAt = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
        final bCreatedAt = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now();

        return aCreatedAt.compareTo(bCreatedAt);
      });

      _choreCategories = categories;
      notifyListeners();
    } catch (e) {
      print('Load chore categories error: $e');
    }
  }

  Future<void> createChoreCategory({
    required String name,
    required String icon,
  }) async {
    try {
      final newCategory = await _apiService.createChoreCategory(
        name: name,
        icon: icon,
      );

      // 새로 생성된 카테고리를 리스트 끝에 추가
      _choreCategories.add(newCategory);
      notifyListeners();
    } catch (e) {
      print('Create chore category error: $e');
      rethrow;
    }
  }

  Future<void> deleteChoreCategory(String categoryId) async {
    try {
      await _apiService.deleteChoreCategory(categoryId);
      _choreCategories.removeWhere((category) => category['_id'] == categoryId);
      notifyListeners();
    } catch (e) {
      print('Delete chore category error: $e');
      rethrow;
    }
  }

  Future<void> loadReservationCategories() async {
    try {
      final categories = await _apiService.getReservationCategories();

      // 생성 순서대로 정렬 (기본 카테고리 먼저, 그 다음 생성시간 순)
      categories.sort((a, b) {
        // 기본 카테고리를 먼저 표시
        final aType = a['type']?.toString() ?? 'custom';
        final bType = b['type']?.toString() ?? 'custom';

        if (aType == 'default' && bType != 'default') return -1;
        if (bType == 'default' && aType != 'default') return 1;

        // 같은 타입이면 생성시간 순 (createdAt 기준)
        final aCreatedAt = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
        final bCreatedAt = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now();

        return aCreatedAt.compareTo(bCreatedAt);
      });

      _reservationCategories = categories;
      notifyListeners();
    } catch (e) {
      print('Load reservation categories error: $e');
    }
  }

  Future<void> createReservationCategory({
    required String name,
    required String icon,
    bool requiresApproval = false,
    bool isVisitor = false,
  }) async {
    try {
      final newCategory = await _apiService.createReservationCategory(
        name: name,
        icon: icon,
        requiresApproval: requiresApproval,
        isVisitor: isVisitor,
      );

      // 새로 생성된 카테고리를 리스트 끝에 추가
      _reservationCategories.add(newCategory);
      notifyListeners();
    } catch (e) {
      print('Create reservation category error: $e');
      rethrow;
    }
  }

  Future<void> deleteReservationCategory(String categoryId) async {
    try {
      await _apiService.deleteReservationCategory(categoryId);
      _reservationCategories.removeWhere((category) => category['_id'] == categoryId);
      notifyListeners();
    } catch (e) {
      print('Delete reservation category error: $e');
      rethrow;
    }
  }

  // ===== 집안일 일정 관련 =====

  Future<void> loadChoreSchedules({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    if (_currentRoom == null) return;

    try {
      // 기본 범위를 더 넓게 설정
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now().add(const Duration(days: 7));

      print('집안일 일정 로드 범위: $start ~ $end'); // 디버깅용
      print('방 ID: ${_currentRoom!.roomId}'); // 디버깅용

      _choreSchedules = await _apiService.getChoreSchedules(
        roomId: _currentRoom!.roomId,
        startDate: start,
        endDate: end,
        categoryId: categoryId,
      );

      print('로드된 집안일 일정: ${_choreSchedules.length}개'); // 디버깅용
      for (var schedule in _choreSchedules) {
        print('일정: ${schedule['category']?['name']}, 날짜: ${schedule['date']}, 담당자: ${schedule['assignedTo']?['nickname']}');
      }

      notifyListeners();
    } catch (e) {
      print('Load chore schedules error: $e');
    }
  }

  Future<void> createChoreSchedule({
    required String categoryId,
    required String assignedTo,
    required DateTime date,
  }) async {
    if (_currentRoom == null) {
      throw Exception('참여 중인 방이 없습니다.');
    }

    try {
      print('집안일 일정 생성 요청:');
      print('- 카테고리 ID: $categoryId');
      print('- 담당자 ID: $assignedTo');
      print('- 날짜: $date');

      final newSchedule = await _apiService.createChoreSchedule(
        roomId: _currentRoom!.roomId,
        categoryId: categoryId,
        assignedTo: assignedTo,
        date: date,
      );

      print('생성된 일정: $newSchedule');

      // 새로 생성된 일정을 바로 리스트에 추가
      _choreSchedules.add(newSchedule);

      // 전체 데이터도 다시 로드하여 최신 상태 유지
      await loadChoreSchedules();

      notifyListeners();
    } catch (e) {
      print('Create chore schedule error: $e');
      rethrow;
    }
  }

  Future<void> completeChoreSchedule(String scheduleId) async {
    try {
      final updatedSchedule = await _apiService.completeChoreSchedule(scheduleId);

      final index = _choreSchedules.indexWhere((schedule) => schedule['_id'] == scheduleId);
      if (index != -1) {
        _choreSchedules[index] = updatedSchedule;
        notifyListeners();
      }
    } catch (e) {
      print('Complete chore schedule error: $e');
      rethrow;
    }
  }

  Future<void> uncompleteChoreSchedule(String scheduleId) async {
    try {
      final updatedSchedule = await _apiService.uncompleteChoreSchedule(scheduleId);

      final index = _choreSchedules.indexWhere((schedule) => schedule['_id'] == scheduleId);
      if (index != -1) {
        _choreSchedules[index] = updatedSchedule;
        notifyListeners();
      }
    } catch (e) {
      print('Uncomplete chore schedule error: $e');
      rethrow;
    }
  }

  Future<void> deleteChoreSchedule(String scheduleId) async {
    try {
      await _apiService.deleteChoreSchedule(scheduleId);

      // 로컬 리스트에서 즉시 제거
      _choreSchedules.removeWhere((schedule) => schedule['_id'] == scheduleId);

      // 전체 데이터 다시 로드
      await loadChoreSchedules();

      notifyListeners();
    } catch (e) {
      print('Delete chore schedule error: $e');
      rethrow;
    }
  }

  // ===== 방문객 예약 관련 =====

  Future<void> loadVisitorReservations() async {
    if (_currentRoom == null) return;

    try {
      _visitorReservations = await _apiService.getVisitorReservations(_currentRoom!.roomId);
      notifyListeners();
    } catch (e) {
      print('Load visitor reservations error: $e');
    }
  }

  Future<void> loadPendingReservations() async {
    if (_currentRoom == null) return;

    try {
      _pendingReservations = await _apiService.getPendingReservations(_currentRoom!.roomId);
      notifyListeners();
    } catch (e) {
      print('Load pending reservations error: $e');
    }
  }

  Future<Map<String, dynamic>> approveReservation(String reservationId) async {
    try {
      final result = await _apiService.approveReservation(reservationId);

      // 방문객 예약과 대기 중인 예약 목록 다시 로드
      await loadVisitorReservations();
      await loadPendingReservations();

      notifyListeners();

      return result;
    } catch (e) {
      print('Approve reservation error: $e');
      rethrow;
    }
  }

  // ===== 예약 일정 관련 =====

  Future<void> loadReservationSchedules({
    DateTime? weekStartDate,
    String? categoryId,
  }) async {
    if (_currentRoom == null) return;

    try {
      _reservationSchedules = await _apiService.getWeeklyReservations(
        roomId: _currentRoom!.roomId,
        weekStartDate: weekStartDate,
        categoryId: categoryId,
      );
      notifyListeners();
    } catch (e) {
      print('Load reservation schedules error: $e');
    }
  }

  // 특정 카테고리의 예약 데이터 로드 (새로 추가)
  Future<void> loadCategoryReservations(String categoryId) async {
    if (_currentRoom == null) return;

    try {
      final reservations = await _apiService.getCategoryWeeklyReservations(
        roomId: _currentRoom!.roomId,
        categoryId: categoryId,
      );

      _categoryReservations[categoryId] = reservations;
      notifyListeners();
    } catch (e) {
      print('Load category reservations error: $e');
    }
  }

  // 특정 카테고리의 예약 데이터 가져오기
  List<Map<String, dynamic>> getCategoryReservations(String categoryId) {
    return _categoryReservations[categoryId] ?? [];
  }

  // 기존 createReservationSchedule 메서드 수정
  Future<void> createReservationSchedule({
    required String categoryId,
    int? dayOfWeek,
    DateTime? specificDate,
    required int startHour,
    required int endHour,
    bool isRecurring = false,
  }) async {
    if (_currentRoom == null) {
      throw Exception('참여 중인 방이 없습니다.');
    }

    try {
      final newSchedule = await _apiService.createReservationSchedule(
        roomId: _currentRoom!.roomId,
        categoryId: categoryId,
        dayOfWeek: dayOfWeek,
        specificDate: specificDate,
        startHour: startHour,
        endHour: endHour,
        isRecurring: isRecurring,
      );

      // 방문객 예약인 경우
      if (specificDate != null) {
        await loadVisitorReservations();
        await loadPendingReservations();
      } else {
        // 일반 예약인 경우 - 해당 카테고리 데이터 업데이트
        await loadCategoryReservations(categoryId);

        // 전체 예약 목록도 업데이트
        _reservationSchedules.add(newSchedule);
      }

      notifyListeners();
    } catch (e) {
      print('Create reservation schedule error: $e');
      rethrow;
    }
  }

  // deleteReservationSchedule 메서드도 수정
  Future<void> deleteReservationSchedule(String scheduleId) async {
    try {
      await _apiService.deleteReservationSchedule(scheduleId);

      // 모든 관련 데이터에서 제거
      _reservationSchedules.removeWhere((schedule) => schedule['_id'] == scheduleId);
      _visitorReservations.removeWhere((schedule) => schedule['_id'] == scheduleId);
      _pendingReservations.removeWhere((schedule) => schedule['_id'] == scheduleId);

      // 카테고리별 데이터에서도 제거
      for (String categoryId in _categoryReservations.keys) {
        _categoryReservations[categoryId]?.removeWhere(
                (schedule) => schedule['_id'] == scheduleId
        );
      }

      notifyListeners();
    } catch (e) {
      print('Delete reservation schedule error: $e');
      rethrow;
    }
  }

  // logout 메서드에 카테고리 데이터 정리 추가
  Future<void> logout() async {
    _currentUser = null;
    _currentUserProfile = null;
    _currentRoom = null;
    _choreCategories = [];
    _reservationCategories = [];
    _choreSchedules = [];
    _reservationSchedules = [];
    _visitorReservations = [];
    _pendingReservations = [];
    _categoryReservations = {};
    _roomMembers = [];
    await _clearUserId();
    notifyListeners();
  }

  // SharedPreferences 관련
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> _clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}