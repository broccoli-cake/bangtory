import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  RoomModel? _currentRoom;
  bool _isLoading = false;
  List<Map<String, dynamic>> _choreCategories = [];
  List<Map<String, dynamic>> _reservationCategories = [];
  List<Map<String, dynamic>> _choreSchedules = [];
  List<Map<String, dynamic>> _reservationSchedules = [];
  List<Map<String, dynamic>> _roomMembers = [];
  List<Map<String, dynamic>> _visitorReservations = [];
  List<Map<String, dynamic>> _pendingReservations = [];

  UserModel? get currentUser => _currentUser;
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

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ===== 사용자 관련 =====

  Future<void> createUser({String? nickname}) async {
    setLoading(true);
    try {
      _currentUser = await _apiService.createUser(nickname: nickname);
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

  Future<void> setProfile({
    required String nickname,
    String? profileImageUrl,
  }) async {
    setLoading(true);
    try {
      _currentUser = await _apiService.setProfile(
        nickname: nickname,
        profileImageUrl: profileImageUrl,
      );
      notifyListeners();
    } catch (e) {
      print('Set profile error: $e');
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
      _choreCategories = await _apiService.getChoreCategories();
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
      _reservationCategories = await _apiService.getReservationCategories();
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
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now().add(const Duration(days: 30));

      _choreSchedules = await _apiService.getChoreSchedules(
        roomId: _currentRoom!.roomId,
        startDate: start,
        endDate: end,
        categoryId: categoryId,
      );
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
      final newSchedule = await _apiService.createChoreSchedule(
        roomId: _currentRoom!.roomId,
        categoryId: categoryId,
        assignedTo: assignedTo,
        date: date,
      );
      _choreSchedules.add(newSchedule);
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

  Future<void> deleteChoreSchedule(String scheduleId) async {
    try {
      await _apiService.deleteChoreSchedule(scheduleId);
      _choreSchedules.removeWhere((schedule) => schedule['_id'] == scheduleId);
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

      // 방문객 예약인 경우 방문객 예약 목록도 업데이트
      if (specificDate != null) {
        await loadVisitorReservations();
        await loadPendingReservations();
      } else {
        _reservationSchedules.add(newSchedule);
      }

      notifyListeners();
    } catch (e) {
      print('Create reservation schedule error: $e');
      rethrow;
    }
  }

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

  Future<void> deleteReservationSchedule(String scheduleId) async {
    try {
      await _apiService.deleteReservationSchedule(scheduleId);

      // 일반 예약 목록에서 제거
      _reservationSchedules.removeWhere((schedule) => schedule['_id'] == scheduleId);

      // 방문객 예약 목록에서 제거
      _visitorReservations.removeWhere((schedule) => schedule['_id'] == scheduleId);

      // 대기 중인 예약 목록에서 제거
      _pendingReservations.removeWhere((schedule) => schedule['_id'] == scheduleId);

      notifyListeners();
    } catch (e) {
      print('Delete reservation schedule error: $e');
      rethrow;
    }
  }



  // ===== 기타 =====

  Future<void> logout() async {
    _currentUser = null;
    _currentRoom = null;
    _choreCategories = [];
    _reservationCategories = [];
    _choreSchedules = [];
    _reservationSchedules = [];
    _visitorReservations = [];
    _pendingReservations = [];
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